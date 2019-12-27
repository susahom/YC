import os
import cv2
import numpy as np
import tensorflow as tf
import glob

from PIL import Image, ImageDraw  #


def prepare_lists(curdir):
    dirs = {}
    label_dict = {}
    names = {}
    path = curdir + "/faces/train"
    dirs = os.listdir(path)
    dirs = [f for f in dirs if os.path.isdir(os.path.join(path, f))]
    i = 0

    for dirname in dirs:
        label_dict[dirname] = i
        i += 1
    names = dirs
    return label_dict,names


def get_batch_list(l, batch_size):
    # [1, 2, 3, 4, 5,...] -> [[1, 2, 3], [4, 5,..]]
    return [np.asarray(l[_:_+batch_size]) for _ in range(0, len(l), batch_size)]


def weight_variable(shape):
    initial = tf.truncated_normal(shape, stddev=0.1)
    return tf.Variable(initial)


def bias_variable(shape):
    initial = tf.constant(0.1, shape=shape)
    return tf.Variable(initial)


def conv2d(x, W):
    return tf.nn.conv2d(x, W, strides=[1, 1, 1, 1], padding='SAME')


def max_pool_2x2(x):
    return tf.nn.max_pool(x, ksize=[1, 2, 2, 1], strides=[1, 2, 2, 1], padding='SAME')


def inference(images_placeholder, keep_prob, label_dict):

    x_image = tf.reshape(images_placeholder, [-1, 32, 32, 3])

    # Convolution layer
    W_conv1 = weight_variable([5, 5, 3, 32])
    b_conv1 = bias_variable([32])
    h_conv1 = tf.nn.relu(conv2d(x_image, W_conv1) + b_conv1)

    # Pooling layer
    h_pool1 = max_pool_2x2(h_conv1)

    # Convolution layer
    W_conv2 = weight_variable([5, 5, 32, 64])
    b_conv2 = bias_variable([64])
    h_conv2 = tf.nn.relu(conv2d(h_pool1, W_conv2) + b_conv2)

    # Pooling layer
    h_pool2 = max_pool_2x2(h_conv2)

    # Full connected layer
    W_fc1 = weight_variable([8 * 8 * 64, 1024])
    b_fc1 = bias_variable([1024])
    h_pool2_flat = tf.reshape(h_pool2, [-1, 8 * 8 * 64])
    h_fc1 = tf.nn.relu(tf.matmul(h_pool2_flat, W_fc1) + b_fc1)

    # Dropout
    h_fc1_drop = tf.nn.dropout(h_fc1, keep_prob)

    # Full connected layer
    W_fc2 = weight_variable([1024, len(label_dict)])
    b_fc2 = bias_variable([len(label_dict)])

    return tf.nn.softmax(tf.matmul(h_fc1_drop, W_fc2) + b_fc2)


# cv2.cv.CV_FOURCC
def cv_fourcc(c1, c2, c3, c4):
    return (ord(c1) & 255) + ((ord(c2) & 255) << 8) + \
        ((ord(c3) & 255) << 16) + ((ord(c4) & 255) << 24)


def setup_detector(curdir):
    label_dict, names = prepare_lists(curdir)
    cascade_file = "haarcascade_frontalface_alt2.xml"
    cascade = cv2.CascadeClassifier(cascade_file)
    x = tf.placeholder('float', shape=[None, 32 * 32 * 3])  # 32 * 32, 3 channels
    keep_prob = tf.placeholder('float')
    y_conv = inference(x, keep_prob,label_dict)
    sess = tf.InteractiveSession()
    sess.run(tf.global_variables_initializer())
    tf.train.Saver().restore(sess, curdir + "/model_face/model.ckpt")
    return label_dict, names, cascade, keep_prob, y_conv, x, sess


def detect_and_mark(label_dict, names, cascade, keep_prob, y_conv, x, sess, cv_mat, markers):


    # 
    img_gray = cv2.cvtColor(cv_mat, cv2.COLOR_BGR2GRAY)
    # img_gray = img
    face_list = cascade.detectMultiScale(img_gray, minSize=(150, 150))

    for (pos_x, pos_y, w, h) in face_list:
        img_face = cv_mat[pos_y:pos_y + h, pos_x:pos_x + w]

        img_face = cv2.resize(img_face, (32, 32))

        test_images = []
        test_images.append(img_face.flatten().astype(np.float32) / 255.0)
        test_images = np.asarray(test_images)

        results = y_conv.eval(feed_dict={x: test_images, keep_prob: 1.0})
        text = names[np.argmax(results[0])]

        color = (0, 0, 225)
        pen_w = 2
        # font = cv2.FONT_HERSHEY_PLAIN
        # font_size = 1.5
        # cv2.putText(cv_mat, text, (pos_x, pos_y - 10), font, font_size, (255, 255, 0))
        # cv2.rectangle(cv_mat, (pos_x, pos_y), (pos_x + w, pos_y + h), color, thickness=pen_w)
        point = (pos_x, pos_y - h)
        haba = (int(w*0.7), int(h*0.7))

        markers_resize = cv2.resize(markers[text], dsize=haba)  #
        # 画像をオーバーレイ
        cv_mat = overlay(cv_mat, markers_resize,  point)  #

    return cv_mat


def close_tfsession(label_dict, names, cascade, keep_prob, y_conv, x, sess):
    sess.close()


def begin_detection(curdir):
    # 定数定義
    ESC_KEY = 27     # Escキー
    INTERVAL= 33     # 待ち時間
    FRAME_RATE = 30  # fps

    WINDOW_NAME = "detect"
    # FILE_NAME = "detect.avi"

    label_dict, names, cascade, keep_prob, y_conv, x, sess = setup_detector(curdir)

    DEVICE_ID = 0
    # カメラ映像取得
    cap = cv2.VideoCapture(DEVICE_ID)

    end_flag, c_frame = cap.read()
    height, width, channels = c_frame.shape

    # 保存ビデオファイルの準備
    # rec = cv2.VideoWriter(FILE_NAME, cv_fourcc('X', 'V', 'I', 'D'), FRAME_RATE, (width, height), True)

    # ウィンドウの準備
    cv2.namedWindow(WINDOW_NAME)

    # マーカー画像を辞書（markers）に格納　key=マーカー画像ファイル名　value=マーカー画像データ
    print('マーカー画像')
    marker_dir = './markers'
    search_pattern = '*.png'
    markers = {}
    # num_markers = len(files)
    # print('マーカー画像の数：' + str(num_markers))
    num_markers = 0
    for marker_path in glob.glob(os.path.join(marker_dir, search_pattern)):
        marker_file_name = os.path.basename(marker_path).split('.', 1)[0]
        markers[marker_file_name] = cv2.imread(marker_path)
        print(marker_file_name)

    # 変換処理ループ
    while end_flag == True:
        img = c_frame
        img = detect_and_mark(label_dict, names, cascade, keep_prob, y_conv, x, sess, img, markers)
        # フレーム表示
        cv2.imshow(WINDOW_NAME, img)
        # フレーム書き込み
        # rec.write(img)

        # Escキーで終了
        key = cv2.waitKey(INTERVAL)
        if key == ESC_KEY:
            break

        # 次のフレーム読み込み
        end_flag, c_frame = cap.read()

    # 終了処理
    close_tfsession(label_dict, names, cascade, keep_prob, y_conv, x, sess)

    cv2.destroyAllWindows()

    cap.release()
    # rec.release()


def overlay(cv_background_image, cv_overlay_image, point,):

    """
     [summary]
    OpenCV形式の画像に指定画像を重ねる
    Parameters
    ----------
    cv_background_image : [OpenCV Image]
    cv_overlay_image : [OpenCV Image]
    point : [(x, y)]
    Returns : [OpenCV Image]
    """
    overlay_height, overlay_width = cv_overlay_image.shape[:2]

    # OpenCV形式の画像をPIL形式に変換(α値含む)
    # 背景画像
    cv_rgb_bg_image = cv2.cvtColor(cv_background_image, cv2.COLOR_BGR2RGB)
    pil_rgb_bg_image = Image.fromarray(cv_rgb_bg_image)
    pil_rgba_bg_image = pil_rgb_bg_image.convert('RGBA')
    # オーバーレイ画像
    cv_rgb_ol_image = cv2.cvtColor(cv_overlay_image, cv2.COLOR_BGRA2RGBA)
    pil_rgb_ol_image = Image.fromarray(cv_rgb_ol_image)
    pil_rgba_ol_image = pil_rgb_ol_image.convert('RGBA')

    # composite()は同サイズ画像同士が必須のため、合成用画像を用意
    pil_rgba_bg_temp = Image.new('RGBA', pil_rgba_bg_image.size,
                                     (255, 255, 255, 0))
    # 座標を指定し重ね合わせる
    pil_rgba_bg_temp.paste(pil_rgba_ol_image, point, pil_rgba_ol_image)
    result_image = \
        Image.alpha_composite(pil_rgba_bg_image, pil_rgba_bg_temp)

    # OpenCV形式画像へ変換
    cv_bgr_result_image = cv2.cvtColor(
        np.asarray(result_image), cv2.COLOR_RGBA2BGRA)

    return cv_bgr_result_image


def cv22pil(image):
    # OpneCV → PIL型
    new_image = image.copy()
    if new_image.ndim == 2:
        pass
    elif new_image.shape[2] == 3:
        new_image = cv2.cvtColor(new_image, cv2.COLOR_BGR2RGB)
    elif new_image.shape[2] == 4:
        new_image = cv2.cvtColor(new_image, cv2.COLOR_BGRA2RGBA)
    new_image = Image.formarray(new_image)
    return new_image


def pil2cv2(image):
    # PIL型 → OpenCV型
    new_image = image.copy()
    if new_image.ndim == 2:
        pass
    elif new_image.shape[2] == 3:
        new_image = cv2.cvtColor(new_image, cv2.COLOR_RGB2BGR)
    elif new_image.shape[2] == 4:
        new_image = cv2.cvtColor(new_image, cv2.COLOR_RGBA2BGRA)
    new_image = Image.formarray(new_image)
    return new_image


if __name__ == "__main__":
    begin_detection(r"D:\CoE_sasa\ICF_AutoCapsule_disabled\ycapture-src-0.1.1\ycapture\WithOpenCV")
