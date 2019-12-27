import os
import random
import cv2
import numpy as np
import tensorflow as tf


path = ""
dirs = {}
label_dict = {}

def load_data(curdir, data_type):

    filenames, images, labels = [], [], []

    walk = filter(lambda _: not len(_[1]) and data_type in _[0], os.walk(curdir + '/faces'))

    for root, dirs, files in walk:
        filenames += ['{}/{}'.format(root, _) for _ in files if not _.startswith('.')]

    # Shuffle files
    random.shuffle(filenames)

    # Read, resize, and reshape images
    images = []
    for file in filenames:
        img = cv2.imread(file)
        img = cv2.resize(img, (32,32))
        images.append(img.flatten().astype(np.float32) / 255.0)
    images = np.asarray(images)

    for filename in filenames:
        label = np.zeros(len(label_dict))
        for k, v in label_dict.items():
            if k in filename:
                label[v] = 1.
        labels.append(label)

    return images, labels

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

def inference(images_placeholder, keep_prob):

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

def begin_training(curdir):
    # セットアップ
    path = curdir + "/faces/train"
    dirs = os.listdir(path)
    dirs = [f for f in dirs if os.path.isdir(os.path.join(path, f))]

    i = 0

    for dirname in dirs:
        label_dict[dirname] = i
        i += 1


    # データ読込
    train_images, train_labels = load_data(curdir, 'train')
    test_images, test_labels = load_data(curdir, 'test')

    print("train_images", len(train_images))
    print("test_images", len(test_images))

    #
    x = tf.placeholder('float', shape=[None, 32 * 32 * 3])  # 32 * 32, 3 channels
    y_ = tf.placeholder('float', shape=[None, len(label_dict)]) # label_dict size
    keep_prob = tf.placeholder('float')
    y_conv = inference(x, keep_prob)

    # Loss function
    cross_entropy = -tf.reduce_sum(y_ * tf.log(y_conv))
    tf.summary.scalar('cross_entropy', cross_entropy)

    # Minimize cross entropy by using SGD
    train_step = tf.train.AdamOptimizer(1e-4).minimize(cross_entropy)

    # Accuracy
    correct_prediction = tf.equal(tf.argmax(y_conv, 1), tf.argmax(y_, 1))
    accuracy = tf.reduce_mean(tf.cast(correct_prediction, 'float'))

    saver = tf.train.Saver()
    sess = tf.InteractiveSession()
    sess.run(tf.global_variables_initializer())

    # Batch
    batch_size = 20
    batched_train_images = get_batch_list(train_images, batch_size)
    batched_train_labels = get_batch_list(train_labels, batch_size)
    # print(len(batched_train_labels))

    train_labels, test_labels = np.asarray(train_labels), np.asarray(test_labels)

    cnt = 0

    accuracys = []

    # Train
    for i in range(15):

        for step, (images, labels) in enumerate(zip(batched_train_images, batched_train_labels)):
            sess.run(train_step, feed_dict={ x: images, y_: labels, keep_prob: 0.5 })
            train_accuracy = accuracy.eval(feed_dict = {
                x: train_images, y_: train_labels, keep_prob: 1.0 })
            accuracys.append(train_accuracy)
            cnt += 1

            print('step {}, training accuracy {}'.format(cnt, train_accuracy))

    # Test trained model
    test_accuracy = accuracy.eval(feed_dict = {
        x: test_images, y_: test_labels, keep_prob: 1.0 })
    print('test accuracy {}'.format(test_accuracy))

    # Save model
    save_path = saver.save(sess, curdir +  "/model_face/model.ckpt")

    sess.close()
    #plt.plot(accuracys)
    #plt.show()


if __name__ == "__main__":
    begin_training(r"D:\CoE_sasa\ICF_AutoCapsule_disabled\ycapture-src-0.1.1\ycapture\WithOpenCV")