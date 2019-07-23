//
//  OpenCVWrapper.m
//  superscaner
//
//  Created by Yanxin on 2019/4/1.
//  Copyright © 2019 Yanxin. All rights reserved.
//
#ifdef __cplusplus
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"


#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"
#import "AICircle.h"
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <math.h>
#pragma clang pop
#endif

using namespace std;
using namespace cv;
#pragma mark - Private Declarations


@interface OpenCVWrapper ()

#ifdef __cplusplus

+ (Mat)_blueFrom:(Mat)source;
+ (Mat)_greenFrom:(Mat)source;
+ (Mat)_redFrom:(Mat)source;
+ (Mat)_lFrom:(Mat)source;
+ (Mat)_aFrom:(Mat)source;
+ (Mat)_bFrom:(Mat)source;
+ (Mat)_matFrom:(UIImage *)source;
+ (UIImage *)_imageFrom:(Mat)source;

#endif

@end

#pragma mark - OpenCVWrapper

@implementation OpenCVWrapper

#pragma mark Public

+ (UIImage *)toBlue:(UIImage *)source {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _blueFrom:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)toGreen:(UIImage *)source {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _greenFrom:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)toRed:(UIImage *)source {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _redFrom:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)toL:(UIImage *)source {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _lFrom:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)toA:(UIImage *)source {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _aFrom:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)toB:(UIImage *)source {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _bFrom:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)Rededge:(UIImage *)source{
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _rededgeFrom:[OpenCVWrapper _matFrom:source]]];
}

+ (UIImage *)Rededge:(UIImage *)source value1:(NSInteger)value1 value2:(NSInteger)value2 value3:(NSInteger)value3 {
    cout << "OpenCV: ";
    return [OpenCVWrapper _imageFrom:[OpenCVWrapper _rededgeFrom:[OpenCVWrapper _matFrom:source] value1:value1 value2:value2 value3:value3]];
}


+ (NSArray *)edgeCircles:(UIImage *)source threshold:(NSInteger)threshold distance:(NSInteger)distance color_selection:(NSInteger)color_selection type:(NSInteger)type gtype:(NSInteger)gtype{
    return [OpenCVWrapper _edgeCircles:[OpenCVWrapper _matFrom:source] threshold:threshold distance:distance color_selection:color_selection type:type gtype:gtype];
}

#pragma mark Private

//　Hough圆检测
+ (NSArray *)_edgeCircles:(Mat)source threshold:(NSInteger)threshold distance:(NSInteger)distance color_selection:(NSInteger)color_selection type:(NSInteger)type gtype:(NSInteger)gtype {
    cout << "-> rededgeFrom ->";
    Mat imageChannel;
    if (color_selection == 0) {
        std::vector<Mat> channels;
        split(source, channels);
        imageChannel = channels.at(type);
    }else if (color_selection == 1){
        Mat lab;
        cvtColor(source, lab, COLOR_BGR2Lab);
        vector<Mat> labPlane;
        split(lab, labPlane);
        imageChannel = labPlane.at(gtype);
    }
    Mat gray;
    cvtColor(source, gray, CV_BGR2GRAY);
    Mat dst1;
    cv::threshold(imageChannel,dst1,0,255,THRESH_OTSU);
    Mat dst2 = 255-dst1;
    //cout<<dst2;
    Mat gaussianBlur;
    GaussianBlur(imageChannel, gaussianBlur, cv::Size(5,5), 2,2);
    //计算最大熵
    const int hannels[1] = { 0 };
    const int histSize[1] = { 256 };
    float pranges[2] = { 0,256 };
    const float* ranges[1] = { pranges };
    MatND hist;
    calcHist(&gaussianBlur, 1, hannels, Mat(), hist, 1, histSize, ranges);
    float maxentropy = 0;
    int max_index = 0;
    float pi = 3.1415926;
    Mat result;
    for (int l = 0; l < 256; l++)
    {
        //
        float BackgroundSum = 0, targetSum = 0;
        const float* pDataHist = (float*)hist.ptr<float>(0);
        for (int i = 0; i < 256; i++)
        {
            //累计背景值
            if (i < l)
            {
                BackgroundSum += pDataHist[i];
            }
            //累计目标值
            else
            {
                targetSum += pDataHist[i];
            }
        }
        
        float BackgroundEntropy = 0, targetEntropy = 0;
        for (int i = 0; i < 256; i++)
        {
            //计算背景熵
            if (i < l)
            {
                if (pDataHist[i] == 0)
                    continue;
                float ratio1 = pDataHist[i] / BackgroundSum;//p[i]
                //计算当前能量熵
                BackgroundEntropy += -ratio1 * logf(ratio1);
            }
            else  //计算目标熵
            {
                if (pDataHist[i] == 0)
                    continue;
                float ratio2 = pDataHist[i] / targetSum;
                targetEntropy += -ratio2 * logf(ratio2);
            }
        }
        //
        float cur_entropy = (targetEntropy + BackgroundEntropy);
        if (cur_entropy > maxentropy)
        {
            maxentropy = cur_entropy;
            max_index = l;
        }
    }
    int MaxThreshold;
    MaxThreshold = max_index;
    Mat edges;
    Canny(gaussianBlur, edges, MaxThreshold/5, MaxThreshold/3);
    //找最大轮廓
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    //cout<<dst1<<endl;
    findContours(dst2, contours, hierarchy, RETR_EXTERNAL, CHAIN_APPROX_NONE);
    //NSLog(@"%lu",contours.size());
    double maxarea = 0;
    int maxAreaIdx = 0;
    for(int index = contours.size()-1;index >=0;index--)
    {
        double tmparea = fabs(contourArea(contours[index]));
        if (tmparea>maxarea)
        {
            maxarea=tmparea;
            maxAreaIdx=index;
        }
    }
    //NSLog(@"%f",maxarea);
    Mat edges1= Mat::zeros(edges.rows,edges.cols,CV_8UC1);
    Mat edges2= Mat::zeros(edges.rows, edges.cols, CV_8UC1);
    Scalar color(255,255,255);
    drawContours(edges1, contours, maxAreaIdx, color, FILLED);
    drawContours(edges2, contours, maxAreaIdx, color, 1);
    //NSLog(@"%i,%i",edges1.cols,edges1.rows);
    cv::Rect ret1 = boundingRect(Mat(contours[maxAreaIdx]));
    NSLog(@"%d,%d,%d,%d",ret1.x,ret1.y,ret1.width,ret1.height);
    int thres = ret1.width + ret1.x;
    int nrow = edges.rows;
    int parts[nrow][1];
    int i,j;
    vector<int> currentGroups;
    vector<Vec4i> newBerries_atEdge;
    vector<Vec4i>group_berries;
    vector<Vec4i> visibleBerries;
    vector<Vec4i> visibleBerries1;
    vector<Vec4i> existing_Berries;
    vector<Vec3f> circles_t;
    Vec4i cf;
    Vec4i ci;
    Vec4i ct;
    Vec4i tmp_fill_berry;
    float bunch_ratio = 5/6;
    for (i=0; i<nrow; i++) {
        for (j=0; j<1; j++) {
            parts[i][j]=1;
        }
    }
    //NSLog(@"%d",thres);
    if (thres < nrow) {
        for (int th=0; th<thres; th++) {
            parts[th][0] = 0;
        }
    }
    
    float track_radius;
    vector<Vec3f> circles;
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    if (distance < imageChannel.cols/3){
        HoughCircles(edges2, circles, HOUGH_GRADIENT, 1, distance*0.5,
                     0.2*255, threshold, distance*0.65, 0.65*distance+10); //image:8位，单通道图像。如果使用彩色图像，需要先转换为灰度图像。method：定义检测图像中圆的方法。目前唯一实现的方法是cv2.HOUGH_GRADIENT。dp：累加器分辨率与图像分辨率的反比。dp获取越大，累加器数组越小。minDist：检测到的圆的中心，（x,y）坐标之间的最小距离。如果minDist太小，则可能导致检测到多个相邻的圆。如果minDist太大，则可能导致很多圆检测不到。param1：用于处理边缘检测的梯度值方法。param2：cv2.HOUGH_GRADIENT方法的累加器阈值。阈值越小，检测到的圈子越多。minRadius：半径的最小大小（以像素为单位）。maxRadius：半径的最大大小（以像素为单位）。
        if (circles.size() < 200){
            //所有的r,x,y
            vector<int> array_r(circles.size());
            for (int i =0; i<circles.size(); i++) {
                array_r[i]=circles[i][2];
                //NSLog(@"%d",array_r[i]);
            }
            vector<int> array_x(circles.size());
            for (int i = 0; i < circles.size(); i++) {
                array_x[i]=circles[i][0];
            }
            vector<int> array_y(circles.size());
            for (int i = 0; i < circles.size(); i++) {
                array_y[i]=circles[i][1];
            }
            //r的四分位点
            
            float MaxValue = 0.0;
            float MinValue = 0.0;
            if (array_r.size()!=0) {
                typedef vector<int>::size_type vec_sz;
                sort(array_r.begin(), array_r.end());
                int ivalsCount = array_r.size();
                float index_Q1 = (ivalsCount + (float)1) / (float)4;
                float iMedianIndex = (ivalsCount+1) / (float)2;
                int iFirst = round(iMedianIndex - 0.5)-1;
                if (iFirst < 0) {
                    iFirst = 0;
                }
                int iNext = round(iMedianIndex + 0.4)-1;
                if (iNext > ivalsCount -1) {
                    iNext = ivalsCount - 1;
                }
                iFirst = round(index_Q1 - 0.5) -1;
                if (iFirst < 0) {
                    iFirst = 0;
                }
                iNext = round(index_Q1 + 0.4)-1;
                if (iNext > ivalsCount - 1) {
                    iNext = ivalsCount -1;
                }
                float value_Q1 = iFirst == iNext? array_r[iNext]: (index_Q1 -1-(float)iFirst)*array_r[iNext]+((float)iNext - index_Q1+1)*array_r[iFirst];
                float index_Q3 = (float)3* (ivalsCount + (float)1) / (float)4;
                iFirst = round(index_Q3 - 0.5)-1;
                if (iFirst < 0) {
                    iFirst = 0;
                }
                iNext = round(index_Q3 - 0.5)-1;
                if (iNext > ivalsCount -1) {
                    iNext = ivalsCount -1;
                }
                float value_Q3 = iFirst == iNext ? array_r[iNext] : (index_Q3-1-(float)iFirst)*array_r[iNext] + ((float)iNext - index_Q3+1)*array_r[iFirst];
                //vec_sz mid, mid1, mid3;
                //double median, median1, median3;
                //mid = array_r.size()/2;
                //median = array_r.size() % 2 ==0? (array_r[mid]+array_r[mid-1])/2.0 : array_r[mid];
                //mid1 = array_r.size()%2==0? (mid-1)/2 : mid/2;
                //mid3 = mid+mid+1;
                //if (array_r.size()%2 !=0) {
                //median1 = mid%2==0? (array_r[mid1]+array_r[mid1-1])/2.0 : array_r[mid1];
                //median3 = mid%2==0? (array_r[mid3]+array_r[mid3-1])/2.0 : array_r[mid3];
                //}
                //else
                //{
                //median1 = (mid-1)%2==0? (array_r[mid1]+array_r[mid1-1])/2.0 : array_r[mid1];
                //median3 = (mid-1)%2==0? (array_r[mid3]+array_r[mid3-1])/2.0 : array_r[mid3];}
                float Spread = 1.5*(value_Q3-value_Q1);
                MaxValue = value_Q3 + Spread;
                MinValue = value_Q1 - Spread;}
            //筛选circles
            
            for(int i = 0;i < circles.size();i++){
                if ((array_r[i]<MaxValue)&&(array_r[i]>MinValue)) {
                    circles_t.push_back(circles[i]);
                }
            }
            //cout<<circles_t.size();
            vector<int> a(circles_t.size());
            for (int i =0; i<circles_t.size(); i++) {
                a[i]=circles_t[i][0];
            }
            vector<int> b(circles_t.size());
            for (int i =0; i<circles_t.size(); i++) {
                b[i]=circles_t[i][1];
            }
            vector<int> r(circles_t.size());
            for (int i =0; i<circles_t.size(); i++) {
                r[i]=circles_t[i][2];
            }
            int group[r.size()][1];
            for (i=0; i<r.size(); i++) {
                for (j=0; j<1; j++) {
                    group[i][j]=0;
                }
            }
            int tolerance = 9;
            float step_move = 0.5;
            float step_radii = 0.01;
            int groupNo = 1;
            bool mark = false;
            for (int i = 0; i < r.size(); i++) {
                float distance[r.size()][1];
                int index[r.size()][1];
                if (group[i][0]==0&&mark) {
                    int i,j;
                    groupNo = group[0][0];
                    for (i=0; i<r.size(); i++) {
                        for (j=0; j<1; j++) {
                            if (group[i][j]>groupNo) {
                                groupNo=group[i][j];
                            }
                        }
                    }
                    groupNo = groupNo+1;
                }else if (group[i][0]>0){
                    groupNo = group[i][0];};
                mark = false;
                for (int j = 0; j<r.size(); j++) {
                    distance[j][0]=sqrt(pow((a[i]-a[j]), 2)+pow((b[i]-b[j]), 2)+pow((r[i]-r[j]), 2));
                    if ((distance[j][0]>0)&&(distance[j][0]<(r[i]+r[j]-tolerance))) {
                        index[j][0]=1;
                    }else{index[j][0]=0;}
                }
                int sum_index = 0;
                int sum_group = 0;
                for (int j=0; j<r.size(); j++) {
                    sum_index = sum_index+index[j][0];
                }
                if (sum_index>0) {
                    
                    for (int j =0; j<r.size(); j++) {
                        if (index[j][0]!=0) {
                            currentGroups.push_back(group[j][0]);
                            sum_group = sum_group + group[j][0];
                            if (sum_group>0) {
                                currentGroups.push_back(groupNo);
                                vector<int>::iterator myMin = min_element(currentGroups.begin(), currentGroups.end());
                                groupNo = *myMin;
                            }
                            group[i][0] = groupNo;
                            for (int j = 0; j<r.size(); j++) {
                                if (index[j][0]!=0) {
                                    group[j][0] = groupNo;
                                }
                            }
                            for (int j = 0; j<currentGroups.size(); j++) {
                                for (int sj = 0; sj<r.size(); sj++) {
                                    if (group[sj][0]==currentGroups[j]) {
                                        group[sj][0] = groupNo;
                                    }
                                }
                            }
                        }
                        mark = true;
                    }
                }
            }
            //adjust berries at egde
            
            
            int max_group = 0;
            for (int i =0; i<r.size(); i++) {
                for (int j =0 ; j<1; j++) {
                    if (group[i][j]>max_group) {
                        max_group = group[i][j];
                    }
                }
            }
            vector<int>tmp_x;
            vector<int>tmp_y;
            vector<int>tmp_r;
            int middle_berry_idx;
            for (int j = 0; j<max_group; j++) {
                if (group[j][0]==j) {
                    tmp_x.push_back(circles_t[j][0]);
                    tmp_y.push_back(circles_t[j][1]);
                    tmp_r.push_back(circles_t[j][2]);
                }
            }
            
            middle_berry_idx = tmp_r.size()/2;
            
            for (int j = 0; j<tmp_r.size(); j++) {
                
                ct[0] = tmp_x[j];
                ct[1] = tmp_y[j];
                ct[2] = 0;
                ct[3] = tmp_r[j];
                group_berries.push_back(ct);
            }
            int candidates[tmp_r.size()][1];
            for (int i = 0; i<tmp_r.size(); i++) {
                for (int j = 0; j<1; j++) {
                    candidates[i][j]=0;
                }
            }
            if (tmp_r.size() > 2) {
                candidates[middle_berry_idx-1][0]=1;
            }
            for (int j = 0; j<tmp_r.size(); j++) {
                if (j!=middle_berry_idx) {
                    while (1) {
                        float distance = sqrt(pow((group_berries[j][0]-group_berries[middle_berry_idx][0]), 2)+pow((group_berries[j][1]-group_berries[middle_berry_idx][1]), 2)+pow((group_berries[j][2]-group_berries[middle_berry_idx][2]), 2));
                        if (distance<=0) {
                            candidates[j][0]=1;
                            break;
                        }
                    }
                }
            }
            newBerries_atEdge.insert(newBerries_atEdge.end(),group_berries.begin(),group_berries.end());
            for (int j = 0; j < r.size(); j++) {
                if (group[j][0]==0) {
                    
                    ci[0] = a[j];
                    ci[1] = b[j];
                    ci[2] = 0;
                    ci[3] = r[j];
                    newBerries_atEdge.push_back(ci);
                }
            }
            //cout<<newBerries_atEdge.size();
            vector<Vec3f> circles2;
            HoughCircles(edges2, circles2, HOUGH_GRADIENT, 1, 0.5*distance,
                         0.1*255, 15, 0.65*distance, 0.65*distance+10 );
            
            for (int i = 0; i < circles2.size(); i++) {
                cf[0] = circles2[i][0];
                cf[1] = circles2[i][1];
                cf[2] = 0;
                cf[3] = circles2[i][2];
                visibleBerries.push_back(cf);
            }
            int candidates1[visibleBerries.size()][1];
            for (int i = 0; i<visibleBerries.size(); i++) {
                for (int j = 0; j<1; j++) {
                    candidates1[i][j]=1;
                }
            }
            for (int i = 0; i < visibleBerries.size(); i++) {
                float distance;
                for (int j = 0; j < r.size(); j++) {
                    distance = sqrt(pow(visibleBerries[i][0]-a[j], 2)+pow(visibleBerries[i][1]-b[j], 2));
                    if (distance < 0 || distance > visibleBerries[i][3]) {
                        vector<Vec4i>::iterator it = visibleBerries.begin()+i;
                        visibleBerries.erase(it);
                        
                    }
                }
            }
            
            
            existing_Berries = newBerries_atEdge;
            //cout<<visibleBerries.size();
            //cout<<0<<endl;
            for (int i = 0; i < visibleBerries.size(); i++) {
                int center_x = visibleBerries[i][0];
                int center_y = visibleBerries[i][1];
                vector<int>v_y = edges.row(center_y).clone();
                vector<int>::iterator idx = find(v_y.begin(), v_y.end(),255);
                long index_min = &*idx-&v_y[0];
                long index_max;
                while (idx != v_y.end()) {
                    idx++;
                    idx = find(idx, v_y.end(),255);
                    if (idx != v_y.end()) {
                        index_max = &*idx-&v_y[0];
                    }
                }
                float majorAxis = (index_max - index_min + 1)/2;
                float track = majorAxis + index_min;
                float minorAxis;
                if (parts[center_y][0]==0) {
                    minorAxis = bunch_ratio*majorAxis;
                    visibleBerries[i][2] = sqrt(abs((1-pow((center_x-track), 2)/pow((majorAxis-visibleBerries[i][3]), 2))*pow((minorAxis-visibleBerries[i][3]), 2)));
                }
                else{
                    track_radius = majorAxis - visibleBerries[i][3];
                    visibleBerries[i][2] = sqrt(abs(pow(track_radius, 2)-pow((center_x-track), 2)));  }
                float distance;
                for (int j = 0; j < existing_Berries.size(); j++) {
                    distance = sqrt(pow(visibleBerries[i][0]-existing_Berries[j][0], 2)+pow(visibleBerries[i][1]-existing_Berries[j][1], 2)+pow(visibleBerries[i][2]-existing_Berries[j][2], 2));
                    while ((distance > 0) && (distance < visibleBerries[i][3]+existing_Berries[j][3]-tolerance)) {
                        visibleBerries[i][2] = visibleBerries[i][2] - step_move;
                    }
                }
            }
            existing_Berries.insert(existing_Berries.end(), visibleBerries.begin(),visibleBerries.end());
            float ar[existing_Berries.size()];
            for (int i = 0; i < existing_Berries.size(); i++) {
                ar[i] = existing_Berries[i][3];
            }
            float sum_r = 0;
            for (int i = 0; i < existing_Berries.size(); i++) {
                sum_r = sum_r + ar[i];
            }
            float muHat = sum_r/existing_Berries.size();
            float sum_s = 0;
            for (int i = 0; i < existing_Berries.size(); i++) {
                sum_s = sum_s + pow(ar[i]-muHat, 2);
            }
            float theta[358];
            for (int i = 1; i < 180; i++) {
                theta[i-1] = i;
            }
            for (int i = 181; i<360; i++) {
                theta[i-2]=i;
            }
            float theta2[30];
            float ac = 1;
            for (int i = 0; i < 30; i++) {
                theta2[i] = ac;
                ac = ac+12;
            }
            float vs = sqrt(sum_s/existing_Berries.size());
            float muci1 = muHat + 1.960*(vs/sqrt(existing_Berries.size()));
            float muci2 = muHat - 1.960*(vs/sqrt(existing_Berries.size()));
            cout<<existing_Berries.size()<<endl;
            cout<<0<<endl;
            for (int i = ret1.y + 5; i < ret1.y + ret1.height - 5; i = i + 2) {
                vector<int>v_y = edges1.row(i).clone();
                //cout<<v_y.size()<<endl;
                vector<int>::iterator idx = find(v_y.begin(), v_y.end(),255);
                long index_min = &*idx-&v_y[0];
                long index_max;
                while (idx != v_y.end()) {
                    idx++;
                    idx = find(idx, v_y.end(),255);
                    if (idx != v_y.end()) {
                        index_max = &*idx-&v_y[0];
                    }
                }
                float majorAxis = (index_max - index_min + 1)/2;
                //NSLog(@"%f",parts[i][0]);
                float track = majorAxis + index_min;
                float minorAxis;
                float tmp_radius;
                srand(time(NULL));
                //NSLog(@"%i",parts[i][0]);
                if (parts[i][0]==0) {
                    minorAxis = 0.8333*majorAxis;
                    for (int ai = 0; ai < 358; ai++) {
                        if (muci1 != INFINITY && muci2 != INFINITY) {
                            tmp_radius = (rand()%100/(float)100)*(muci1-muci2) + muHat;
                        }else{tmp_radius = muHat;}
                        //cout<<tmp_radius<<endl;
                        float tmp_fill_berry0, tmp_fill_berry1, tmp_fill_berry2, tmp_fill_berry3;
                        tmp_fill_berry0 = track + (majorAxis - tmp_radius)*cos(theta[ai]/180*pi);
                        tmp_fill_berry1 = i;
                        
                        tmp_fill_berry2 = (minorAxis - tmp_radius)*sin(theta[ai]/180*pi);
                        //NSLog(@"%f",(theta[i]/180)*pi);
                        tmp_fill_berry3 = tmp_radius;
                        tmp_fill_berry[0] = tmp_fill_berry0;
                        tmp_fill_berry[1] = tmp_fill_berry1;
                        tmp_fill_berry[2] = tmp_fill_berry2;
                        tmp_fill_berry[3] = tmp_fill_berry3;
                        //NSLog(@"(%i,%i,%d,%i)",tmp_fill_berry[0],tmp_fill_berry[1],tmp_fill_berry[2],tmp_fill_berry[3]);
                        float tmpX = tmp_fill_berry1;
                        float tmpY = tmp_fill_berry0;
                        float distance;
                        float tmp_radius1;
                        tmp_radius1 = tmp_radius*0.8;
                        float xx[30];
                        float yy[30];
                        int ind2 = 0;
                        int ind1 = 0;
                        bool index2 = false;
                        for (int j = 0; j<30; j++) {
                            xx[j] = tmpX + tmp_radius1*cos(theta2[j]/180*pi);
                            yy[j] = tmpY + tmp_radius1*sin(theta2[j]/180*pi);
                            //NSLog(@"%i,%i",edges1.cols,edges2.cols);
                            if ((xx[j]*yy[j] > 0)&&(round(xx[j]) < edges1.rows)&&(round(yy[j]) < edges1.cols)) {
                                ind1 = edges1.at<uchar>(round(xx[j]),round(yy[j]));
                                //NSLog(@"%i",ind1);
                                if (ind1 == 255) {
                                    ind2++;
                                }
                            }else{index2 = false;}
                        }
                        if (ind2 == 30 ) {
                            index2 = true;
                        }
                        int index1 = 0;
                        for (int j = 0 ; j < existing_Berries.size(); j++) {
                            distance = sqrt(pow(tmp_fill_berry0-existing_Berries[j][0], 2)+pow(tmp_fill_berry1-existing_Berries[j][1], 2)+pow(tmp_fill_berry2-existing_Berries[j][2], 2));
                            if ((distance>0)&&(distance<tmp_fill_berry3+existing_Berries[j][3]-tolerance)) {
                                
                                index1 = index1+1;
                            }
                        }
                        if ((index1==0)&&index2) {
                            NSLog(@"(%d,%d,%d,%d)",tmp_fill_berry[0],tmp_fill_berry[1],tmp_fill_berry[2],tmp_fill_berry[3]);
                            cout<<1<<endl;
                            existing_Berries.push_back(tmp_fill_berry);
                        }
                    }
                }else{
                    track_radius = majorAxis;
                    minorAxis = 0.8333*majorAxis;
                    for (int ai = 0; ai < 358; ai++) {
                        if (muci1 != INFINITY && muci2 != INFINITY) {
                            tmp_radius = (rand()%100/(double)101)*(muci1-muci2) + muHat;
                        }else{tmp_radius = muHat;}
                        
                        float tmp_fill_berry0, tmp_fill_berry1, tmp_fill_berry2, tmp_fill_berry3;
                        tmp_fill_berry0 = track + (track_radius - tmp_radius)*cos(theta[ai]/180*pi);
                        tmp_fill_berry1 = i;
                        
                        tmp_fill_berry2 = (track_radius - tmp_radius)*sin(theta[ai]/180*pi);
                        //NSLog(@"%f",track_radius - tmp_radius);
                        tmp_fill_berry3 = tmp_radius;
                        tmp_fill_berry[0] = tmp_fill_berry0;
                        tmp_fill_berry[1] = tmp_fill_berry1;
                        tmp_fill_berry[2] = tmp_fill_berry2;
                        tmp_fill_berry[3] = tmp_fill_berry3;
                        //NSLog(@"(%i,%i,%d,%i)",tmp_fill_berry[0],tmp_fill_berry[1],tmp_fill_berry[2],tmp_fill_berry[3]);
                        float tmpX = tmp_fill_berry1;
                        float tmpY = tmp_fill_berry0;
                        float distance;
                        float tmp_radius1;
                        tmp_radius1 = tmp_radius*0.8;
                        float xx[30];
                        float yy[30];
                        int ind2 = 0;
                        int ind1 = 0;
                        bool index2 = false;
                        for (int j = 0; j<30; j++) {
                            xx[j] = tmpX + tmp_radius1*cos(theta2[j]/180*pi);
                            yy[j] = tmpY + tmp_radius1*sin(theta2[j]/180*pi);
                            if ((xx[j]*yy[j] > 0)&&(round(xx[j]) < edges1.rows)&&(round(yy[j]) < edges1.cols)) {
                                ind1 = edges1.at<uchar>(round(xx[j]),round(yy[j]));
                                if (ind1 == 255) {
                                    ind2++;
                                }
                            }else{index2 = false;}
                        }
                        if (ind2 == 30 ) {
                            index2 = true;
                        }
                        int index1 = 0;
                        for (int j = 0 ; j < existing_Berries.size(); j++) {
                            distance = sqrt(pow(tmp_fill_berry0-existing_Berries[j][0], 2)+pow(tmp_fill_berry1-existing_Berries[j][1], 2)+pow(tmp_fill_berry2-existing_Berries[j][2], 2));
                            if ((distance>0)&&(distance<tmp_fill_berry3+existing_Berries[j][3]-tolerance)) {
                                index1 = index1+1;
                            }
                        }
                        if ((index1==0)&&index2) {
                            NSLog(@"(%d,%d,%f,%d)",tmp_fill_berry[0],tmp_fill_berry[1],minorAxis,tmp_fill_berry[3]);
                            cout<<2<<endl;
                            existing_Berries.push_back(tmp_fill_berry);
                        }
                    }
                    
                }
            }
            cout<<existing_Berries.size();
            //cout<<0<<endl;
            for( size_t i = 0; i < existing_Berries.size(); i++ ) {
                Vec3i c;
                int z;
                c[0] = existing_Berries[i][0];
                c[1] = existing_Berries[i][1];
                c[2] = existing_Berries[i][3];
                z = existing_Berries[i][2];
                AICircle *circle = [[AICircle alloc] init];
                circle.x = [NSNumber numberWithFloat:c[0]];
                circle.y = [NSNumber numberWithFloat:c[1]];
                circle.r = [NSNumber numberWithFloat:c[2]];
                NSLog(@"(%d,%d,%d,%d)",c[0],c[1],z,c[2]);
                circle.z = [NSNumber numberWithInteger:z];
                [arr addObject:circle];
            }
        }else{
            AICircle *circle = [[AICircle alloc] init];
            circle.x = [NSNumber numberWithFloat:0];
            circle.y = [NSNumber numberWithFloat:0];
            circle.r = [NSNumber numberWithFloat:0];
            circle.z = [NSNumber numberWithInteger:0];
            [arr addObject:circle];
        }
    }
    else{
        AICircle *circle = [[AICircle alloc] init];
        circle.x = [NSNumber numberWithFloat:0];
        circle.y = [NSNumber numberWithFloat:0];
        circle.r = [NSNumber numberWithFloat:0];
        circle.z = [NSNumber numberWithInteger:0];
        [arr addObject:circle];
    }
    return arr;
}

//　Hough圆检测
+ (Mat)_rededgeFrom:(Mat)source value1:(NSInteger)value1 value2:(NSInteger)value2 value3:(NSInteger)value3 {
    cout << "-> hough ->";
    Mat gaussianBlur;
    GaussianBlur(source, gaussianBlur, cv::Size(5,5), 2,2);
    Mat edges;
    Canny(gaussianBlur, edges, 0, 50);
    vector<Vec3f> circles;
    HoughCircles(edges, circles, HOUGH_GRADIENT, 1, 50,
                 1, value1,(int)value2, (int)value3 ); //image:8位，单通道图像。如果使用彩色图像，需要先转换为灰度图像。method：定义检测图像中圆的方法。目前唯一实现的方法是cv2.HOUGH_GRADIENT。dp：累加器分辨率与图像分辨率的反比。dp获取越大，累加器数组越小。minDist：检测到的圆的中心，（x,y）坐标之间的最小距离。如果minDist太小，则可能导致检测到多个相邻的圆。如果minDist太大，则可能导致很多圆检测不到。param1：用于处理边缘检测的梯度值方法。param2：cv2.HOUGH_GRADIENT方法的累加器阈值。阈值越小，检测到的圈子越多。minRadius：半径的最小大小（以像素为单位）。maxRadius：半径的最大大小（以像素为单位）。
    
    for( size_t i = 0; i < circles.size(); i++ )
    {
        Vec3i c = circles[i];
        circle( source, Point2i(c[0], c[1]), c[2], Scalar(0,255,0), 0.1);
        circle( source, Point2i(c[0], c[1]), 2, Scalar(0,255,0), 0.1);
        
    }
    return source;
    
}

//　Hough圆检测
+ (Mat)_rededgeFrom:(Mat)source {
    cout << "-> rededgeFrom ->";
    
    std::vector<Mat> channels;
    Mat imageRedChannel;
    
    //把一个三通道图像转化为三个单通道图像
    Mat gaussianBlur;
    GaussianBlur(source, gaussianBlur, cv::Size(5,5), 2,2);
    Mat edges;
    Canny(gaussianBlur, edges, 0, 50);
    vector<Vec3f> circles;
    HoughCircles(edges, circles, HOUGH_GRADIENT, 1, 10,
                 1, 79, 150, 250 ); //image:8位，单通道图像。如果使用彩色图像，需要先转换为灰度图像。method：定义检测图像中圆的方法。目前唯一实现的方法是cv2.HOUGH_GRADIENT。dp：累加器分辨率与图像分辨率的反比。dp获取越大，累加器数组越小。minDist：检测到的圆的中心，（x,y）坐标之间的最小距离。如果minDist太小，则可能导致检测到多个相邻的圆。如果minDist太大，则可能导致很多圆检测不到。param1：用于处理边缘检测的梯度值方法。param2：cv2.HOUGH_GRADIENT方法的累加器阈值。阈值越小，检测到的圈子越多。minRadius：半径的最小大小（以像素为单位）。maxRadius：半径的最大大小（以像素为单位）。
    
    for( size_t i = 0; i < circles.size(); i++ )
    {
        Vec3i c = circles[i];
        circle( source, Point2i(c[0], c[1]), c[2], Scalar(0,255,0), 10);
        circle( source, Point2i(c[0], c[1]), 2, Scalar(0,255,0), 10);
        
    }
    return source;
    
}

//RGB色彩分离
+ (Mat)_blueFrom:(Mat)source {
    cout << "-> blueFrom ->";
    
    std::vector<Mat> channels;
    Mat imageBlueChannel;
    
    //把一个三通道图像转化为三个单通道图像
    split(source, channels);
    imageBlueChannel = channels.at(0);
    Mat dst1;
    cv::threshold(imageBlueChannel,dst1,0,255,THRESH_OTSU);
    Mat dst2 = 255-dst1;    //显示分离的单通道图像
    return imageBlueChannel;
    
}

+ (Mat)_greenFrom:(Mat)source {
    cout << "-> greenFrom ->";
    
    std::vector<Mat> channels;
    Mat imageGreenChannel;
    
    //把一个三通道图像转化为三个单通道图像
    split(source, channels);
    imageGreenChannel = channels.at(1);
    
    //显示分离的单通道图像
    
    return imageGreenChannel;
    
}

+ (Mat)_redFrom:(Mat)source {
    cout << "-> redFrom ->";
    
    std::vector<Mat> channels;
    Mat imageRedChannel;
    
    //把一个三通道图像转化为三个单通道图像
    split(source, channels);
    imageRedChannel = channels.at(2);
    
    //显示分离的单通道图像
    
    return imageRedChannel;
    
}

//LAB色彩分离
+ (Mat)_lFrom:(cv::Mat)source{
    cout << "-> lFrom ->";
    
    Mat lab;
    cvtColor(source, lab, COLOR_BGR2Lab);//转LAB色彩空间
    vector<Mat> labPlane;
    Mat imageLChannel;
    split(lab, labPlane);//LAB色彩分离
    imageLChannel = labPlane.at(0);
    
    return imageLChannel;
}

+ (Mat)_aFrom:(cv::Mat)source{
    cout << "-> aFrom ->";
    
    Mat lab;
    cvtColor(source, lab, COLOR_BGR2Lab);
    vector<Mat> labPlane;
    Mat imageAChannel;
    split(lab, labPlane);
    imageAChannel = labPlane.at(1);
    
    return imageAChannel;
}

+ (Mat)_bFrom:(cv::Mat)source{
    cout << "-> bFrom ->";
    
    Mat lab;
    cvtColor(source, lab, COLOR_BGR2Lab);
    vector<Mat> labPlane;
    Mat imageBChannel;
    split(lab, labPlane);
    imageBChannel = labPlane.at(2);
    
    return imageBChannel;
}

+ (Mat)_matFrom:(UIImage *)source {
    cout << "matFrom ->";
    
    CGImageRef image = CGImageCreateCopy(source.CGImage);
    CGFloat cols = CGImageGetWidth(image);
    CGFloat rows = CGImageGetHeight(image);
    Mat result(rows, cols, CV_8UC4);
    
    CGBitmapInfo bitmapFlags = kCGImageAlphaNoneSkipLast | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = result.step[0];
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image);
    
    CGContextRef context = CGBitmapContextCreate(result.data, cols, rows, bitsPerComponent, bytesPerRow, colorSpace, bitmapFlags);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, cols, rows), image);
    CGContextRelease(context);
    
    return result;
}

+ (UIImage *)_imageFrom:(Mat)source {
    cout << "-> imageFrom\n";
    
    NSData *data = [NSData dataWithBytes:source.data length:source.elemSize() * source.total()];
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    CGBitmapInfo bitmapFlags = kCGImageAlphaNone | kCGBitmapByteOrderDefault;
    size_t bitsPerComponent = 8;
    size_t bytesPerRow = source.step[0];
    CGColorSpaceRef colorSpace = (source.elemSize() == 1 ? CGColorSpaceCreateDeviceGray() : CGColorSpaceCreateDeviceRGB());
    
    CGImageRef image = CGImageCreate(source.cols, source.rows, bitsPerComponent, bitsPerComponent * source.elemSize(), bytesPerRow, colorSpace, bitmapFlags, provider, NULL, false, kCGRenderingIntentDefault);
    UIImage *result = [UIImage imageWithCGImage:image];
    
    CGImageRelease(image);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return result;
}


@end
