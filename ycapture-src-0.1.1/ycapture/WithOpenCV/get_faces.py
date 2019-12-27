import os
import sys
import time
from datetime import datetime as dt
import cv2
import numpy as np
from PIL import Image, ImageDraw
import random

name = sys.argv[-1]
print(name)

cascade_file = "haarcascade_frontalface_alt2.xml"
cascade = cv2.CascadeClassifier(cascade_file)

cnt_max = 3
cnt_face = 0
faces = []

# カメラ取り込み開始
DEVICE_ID = 0
cap = cv2.VideoCapture(DEVICE_ID)

# 初期フレームの取得
time.sleep(1)
end_flag, c_frame = cap.read()
height, width, channels = c_frame.shape

while cnt_face < cnt_max:

    img = c_frame

    img_gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    face_list = cascade.detectMultiScale(img_gray, minSize=(100, 100))

    for (pos_x, pos_y, w, h) in face_list:

        # 顔の切出
        img_face = img[pos_y:pos_y+h, pos_x:pos_x+w]
        # 画像サイズ変更
        img_face = cv2.resize(img_face, (100, 100))
        faces.append(img_face)

    if len(face_list) > 0:
        cnt_face += 1
        print("\r", cnt_face, end="")

    time.sleep(1)
    end_flag, c_frame = cap.read()

cap.release()

print(len(faces))

num = 0
tdatetime = dt.now()
tstr = tdatetime.strftime('%Y%m%d%H%M')

# 学習データ
path = '{}/faces/train/{}'.format(os.getcwd(), name)
print("学習データ", path)
# フォルダが既存->既存フォルダ削除、新規フォルダ作成、ファイル保存（未実装）
# フォルダがない->新規フォルダ作成、ファイル保存（未実装）
os.makedirs(path)

for face in faces[:-1]:
    filename = '{}-{}.jpg'.format(tstr, num)
    print("\t", filename)
    cv2.imwrite('{}/{}'.format(path, filename), face)
    num += 1

# テストデータ
path = '{}/faces/test/{}'.format(os.getcwd(), name)
print("テストデータ", path)
os.makedirs(path)

face = faces[-1]
filename = '{}-{}.jpg'.format(tstr, num)
print("\t", filename)
cv2.imwrite('{}/{}'.format(path, filename), face)

# 矢印マーカー画像
# # 画像サイズ
image_size = 200
# # 矢印マスク画像
mask = np.zeros((image_size, image_size))
pts_arrow = np.array(((int(image_size/4), 0),
                ((int(image_size/4)), (int(image_size/2))),
                (0, int(image_size/2)),
                (int(image_size/2), image_size),
                (image_size, int(image_size/2)),
                (int(image_size/4*3), int(image_size/2)),
                (int(image_size/4*3), 0)))
cv2.fillPoly(mask, [pts_arrow], (1, 1, 1))

# # マーカー画像
# marker, _ = random_shapes((image_size, image_size), min_shapes=10, max_shapes=20,
#                           min_size=20, allow_overlap=True)


def make_marker(size_marker, num_shape_min, num_shape_max):
    marker_img = np.zeros((size_marker, size_marker))
    num_shape = random.randint(num_shape_min, num_shape_max)
    i = 0
    while i <= num_shape:
        shape_pattern = random.randint(1, 10)
        shape_pnt_x1 = random.randint(int(size_marker/4), int(size_marker/4*3))
        shape_pnt_x2 = random.randint(10, size_marker - 10)
        shape_pnt_y1 = random.randint(0, int(size_marker/2))
        shape_pnt_y2 = random.randint(int(size_marker/2), size_marker - 5)
        shape_size = random.randint(10, int(size_marker/8))
        if shape_pattern <= 7:
            cv2.rectangle(marker_img,
                          (shape_pnt_x1, shape_pnt_y1),
                          (shape_pnt_x1+shape_size, shape_pnt_y1+shape_size),
                          (255, 255, 255))
            cv2.rectangle(marker_img,
                          (shape_pnt_x2, shape_pnt_y2),
                          (shape_pnt_x2+shape_size, shape_pnt_y2+shape_size),
                          (255, 255, 255))
        elif shape_pattern == 8:
            pts = np.array(((shape_pnt_x1, shape_pnt_y1),
                            (shape_pnt_x2, shape_pnt_y2),
                            (int(abs(shape_pnt_x1-shape_pnt_x2)/2), shape_pnt_y1+shape_pnt_y2)))
            cv2.polylines(marker_img, [pts], True, (255, 255, 255))
        elif shape_pattern == 9:
            pts = np.array(((shape_pnt_x1, shape_pnt_y1),
                            (int(shape_pnt_x1-shape_size/2), shape_pnt_y1+shape_size),
                            (int(shape_pnt_x1+shape_size/2), shape_pnt_y1+shape_size)))
            cv2.polylines(marker_img, [pts], True, (255, 255, 255))
            pts = np.array(((shape_pnt_x1, shape_pnt_y1+shape_size+30),
                           (int(shape_pnt_x1-shape_size/2), shape_pnt_y1+30),
                           (int(shape_pnt_x1+shape_size/2), shape_pnt_y1+30)))
            cv2.polylines(marker_img, [pts], True, (255, 255, 255))
        else:
            cv2.line(marker_img, (shape_pnt_x1, shape_pnt_y1),
                          (shape_pnt_x1+shape_size, shape_pnt_y1+shape_size), (255, 255, 255))
        i += 1
        print('shape:' + str(i))
    return marker_img


marker = make_marker(image_size, 30, 50)


# # 矢印マーカー画像
masked_marker = mask * marker
cv2.polylines(masked_marker, [pts_arrow], True, (255, 255, 255), thickness=2)
masked_marker = np.where(masked_marker < 255, 255, 0)


# # 保存
filename = '{}.png'.format(name)
path = '{}/markers/'.format(os.getcwd())
print("マーカー ", path)
cv2.imwrite('{}/{}'.format(path, filename), masked_marker)

print('get_faces完了')