# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# %%   This file is part of SparseSampling@TPAMI2020.
# %
# %    SparseSampling@TPAMI2020 is free software: you can redistribute it and/or modify
# %    it under the terms of the GNU General Public License as published by
# %    the Free Software Foundation, either version 3 of the License, or
# %    (at your option) any later version.
# %
# %    SparseSampling@TPAMI2020 is distributed in the hope that it will be useful,
# %    but WITHOUT ANY WARRANTY; without even the implied warranty of
# %    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# %    GNU General Public License for more details.
# %
# %    You should have received a copy of the GNU General Public License
# %    along with SparseSampling@TPAMI2020.  If not, see <http://www.gnu.org/licenses/>.
# %
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


import sys
import numpy as np
import cv2

argc = len(sys.argv)
classes = 80

def loadYoloData(yolo_lines):
    descriptors = np.zeros((framecount, classes), dtype=np.int16)
    i = 0
    while i < len(yolo_lines):
        objects = (int)((float)(yolo_lines[i].rsplit(',')[0]))
        current_frame = (int)((float)(yolo_lines[i].rsplit(',')[1]))
        i+=1;
        for j in xrange(objects):
            obj_line = (yolo_lines[i+j].rsplit(','));
            yolo_class = (int)(obj_line[0]);
            descriptors[current_frame, yolo_class] += 1

        i += objects
    
    return descriptors

if __name__ == '__main__':
    
    if argc < 3:
        print "USAGE ERROR: python generate_descriptor.py <video_path> <yolo_extraction> <desc_output>"
        exit();

    cap = cv2.VideoCapture(sys.argv[1])
    YoloLines = open(sys.argv[2], 'r').readlines()

    framecount = (int)(cap.get(cv2.cv.CV_CAP_PROP_FRAME_COUNT))
    descriptors = loadYoloData(YoloLines)

    np.savetxt(sys.argv[3], descriptors, delimiter=",", fmt='%i')

    print "Total objects: ", np.sum(descriptors)
    print "Done :)"
