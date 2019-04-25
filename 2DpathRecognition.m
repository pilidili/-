%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Copyright: Copyright (c) 2018
%Created on 2018-6-16 
%Author:MengDa (github:pilidili)
%Version 1.0 
%Title: 2DpathRecognition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear;clc;close all;
disp('Initializing...');
t1=clock;%��ʼ�����ּ�ʱ��ʼ
%%%%%%%%�����ѹ��ͼƬ%%%%%%%%
I_origin=imread('f.jpg');
I_Singelpic_Size=1024;
I_resize_Size=512;
I_origin=imresize(I_origin,I_resize_Size/I_Singelpic_Size);
I_origin_Size=size(I_origin);
spop_start=[I_origin_Size(2)-I_resize_Size,(I_origin_Size(1)-I_resize_Size)/2];%��һ��������ԭ�����꣨Singel Picture Original Point��
I=I_origin(spop_start(2)+1:spop_start(2)+I_resize_Size,spop_start(1)+1:I_origin_Size(2),:);%��ȡ��һ��������
%%%%%%%%����ʶ���߶˵�洢�ռ�%%%%%%%%
lpm=zeros(ceil(I_resize_Size/10),2,ceil(I_origin_Size(2)/I_resize_Size)+1);
%%%%%%%%���ٸ���������ԭ������洢�ռ�%%%%%%%%
opm=zeros(ceil(I_origin_Size(2)/I_resize_Size)+1,2);
opm(1,:)=spop_start;
%%%%%%%%���ٸ�������������ʱ��Ĵ洢�ռ�%%%%%%%%
time_m=zeros(1,ceil(I_origin_Size(2)/I_resize_Size)+1);
%%%%%%%%����·���ж���������%%%%
unit_scale=35;%�����ߴ�
x=[(1:(unit_scale-1))-0.5,(unit_scale-1)*ones(1,unit_scale-1),unit_scale-0.5-(1:(unit_scale-1))];
y=[floor(unit_scale/2)*ones(1,unit_scale-1),unit_scale/2-(1:(unit_scale-1)),-floor(unit_scale/2)*ones(1,unit_scale-1)];
k_switch=[y./x,-inf];%�����ж�б������
x_delta=[-(0:unit_scale-2),-(unit_scale-1)*ones(1,unit_scale),(0:unit_scale-2)-unit_scale+2];
y_delta=[-floor(unit_scale/2)*ones(1,unit_scale),(1:unit_scale-2)-floor(unit_scale/2),floor(unit_scale/2)*ones(1,unit_scale)];
P_delta=[x_delta',y_delta'];%���������Ӧ����仯��
d_d=dcm(unit_scale);%����б�����������
t2=clock;
time_int=etime(t2,t1);%��ʼ�����ּ�ʱ����


clc
disp('calculating...');
t1=clock;%���㲿�ּ�ʱ��ʼ
%%%%%%%%��㶨λ%%%%%%%%
%%%% x���궨λ %%%%
qtdc_size_x=32;%������Ѳ����ߴ�
qtdc_storage_x=zeros(qtdc_size_x,I_resize_Size);%����������ѽ���洢�ռ�
for ii=1:I_resize_Size/qtdc_size_x %��������㷨��x��������
    pp=qtdc_size_x*(ii-1)+1:qtdc_size_x*(ii);
    I_q=qtdecomp(I(1:qtdc_size_x,pp),0.05);
    qtdc_storage_x(:,pp)=I_q;
end
sum_x=sum(qtdc_storage_x); %������ѽ��������ͽ�ά
sum_x=edge(sum_x,'roberts',1); %����roberts�������ݶ����ӣ����߽�
sum_x=bwareaopen(sum_x,50); %������ͨ����ȥ��С����ı߽�
x_start=find(sum_x,1,'first'); %���������x����


%%%% y���궨λ %%%%
qtdc_size_y=32;
if x_start>qtdc_size_y  %%�����ж�
    range=x_start-qtdc_size_y+1:x_start;
    qtdc_storage_y=zeros(I_resize_Size,qtdc_size_y);  %����������ѽ���洢�ռ�
    for ii=1:I_resize_Size/qtdc_size_y  %��������㷨��y��������
        pp=qtdc_size_y*(ii-1)+1:qtdc_size_y*(ii);
        I_q_y=qtdecomp(I(pp,range),0.05);
        qtdc_storage_y(pp,:)=I_q_y;
    end
    sum_y=sum(qtdc_storage_y,2);%������ѽ��������ͽ�ά

    y_sum_fft=fft(sum_y);  %��ͨ�˲�
    y_sum_fft(10:end)=0;
    sum_y=real(ifft(y_sum_fft));
else %%���󶪳�
    clc;
    disp('---ERROR---');
    disp('Start point not found!');
    return;
end
[maxsum,y_start]=max(sum_y); %�󼫴�ֵ������x����


%%%% �������ɼ�������ϵת�� %%%%
point_mini=[x_start,y_start];%�������(��������������ϵ)
origin_big=spop_start;%���õ�ǰ���������ԭ�㣨����̨����ϵ��



jj=1;%�����������
while origin_big(1)> 0 && origin_big(2)> 0  && ...
        origin_big(1)<=(I_origin_Size(2)-I_resize_Size) && origin_big(2)<=(I_origin_Size(1)-I_resize_Size)
    
    I=I_origin(origin_big(2)+1:origin_big(2)+I_resize_Size,origin_big(1)+1:origin_big(1)+I_resize_Size,:);    
    lpm(1,:,jj)=point_mini+origin_big;
    ii=1;

    %%%%%%%%ʶ���ѷ�%%%%%%%%
    while point_mini(1)>spop_start(1)+x_start-2802 && point_mini(2)>unit_scale  && ...
            point_mini(1)<=I_resize_Size && point_mini(2)<=(I_resize_Size-floor(unit_scale/2))
        ii=ii+1;
        x_range=point_mini(1)-unit_scale+1:point_mini(1);
        y_range=point_mini(2)-floor((unit_scale-1)/2):point_mini(2)+floor(unit_scale/2);
        I_current=I(y_range,x_range,:);
        if point_mini(1)+origin_big(1)<1055 %�������л���ֵ
            I_current=1-im2bw(I_current,0.25);
            I_current(1,1)=1;
        else
            I_current=1-im2bw(I_current,0.4);
        end
        if sum(sum(I_current))==0 || (sum(sum(I_current.*[ones(unit_scale,ceil(unit_scale*2/3)),zeros(unit_scale,floor(unit_scale*1/3))]))==0)%%����ʧ���� ���£�y����������
            x_range=point_mini(1)-floor((unit_scale-1)/2):point_mini(1)+floor(unit_scale/2);
            y_range=point_mini(2):point_mini(2)+unit_scale-1;
            I_current=I_origin(y_range+origin_big(2),x_range+origin_big(1),:);
            I_current=imrotate(I_current, -90);
            I_current=1-im2bw(I_current,0.4);
            if sum(sum(I_current))==0 %%���Դ�ʧ���� ���ϣ�-y����������
                x_range=point_mini(1)-floor((unit_scale-1)/2):point_mini(1)+floor(unit_scale/2);
                y_range=point_mini(2)-unit_scale+1:point_mini(2);
                I_current=I_origin(y_range+origin_big(2),x_range+origin_big(1),:);
                I_current=imrotate(I_current,90);
                I_current=1-im2bw(I_current,0.4);
                if sum(sum(I_current))==0  %%����Ȼ��ʧ���� �����˳�
                    clc;
                    disp('---ERROR---');
                    disp('Missing the curve!');
                    return;
                else %�����ҵ����
                    p=sum(sum(I_current.*d_d))/sum(sum(I_current));
                    Pixal_out=find(k_switch<p(1),1,'first');
                    pos_delta=fliplr(P_delta(Pixal_out,:)).*[-1,1];
                end
            else  %�����ҵ����
                p=sum(sum(I_current.*d_d))/sum(sum(I_current));
                Pixal_out=find(k_switch<p(1),1,'first');
                pos_delta=fliplr(P_delta(Pixal_out,:)).*[1,-1];
            end
        else %�������
            p=sum(sum(I_current.*d_d))/sum(sum(I_current));
            Pixal_out=find(k_switch<p(1),1,'first');
            pos_delta=P_delta(Pixal_out,:);
        end
        point_mini=point_mini+pos_delta;
        lpm(ii,:,jj)=point_mini+origin_big;
    end
    t2=clock;
    time_m(jj)=etime(t2,t1);%��ʱһ��
    t1=clock;
    
    origin_big=point_mini+origin_big-[I_resize_Size,I_resize_Size/2];%������һ��ѭ�������ԭ��λ��(����̨����ϵ)
    point_mini=[I_resize_Size,I_resize_Size/2]; %������һ��ѭ���ĳ�ʼ��λ��(��������������ϵ)
    jj=jj+1;
    opm(jj,:)=origin_big;
end
opm=opm(1:end-1,:);

%%%%%%%%��ͼ������%%%%%%%%
clc
disp('plotting...');
t1=clock;%��ͼ���ּ�ʱ��ʼ
imshow(I_origin);
hold on;
for ii=1:size(lpm,3); %����ʶ������ѷ��߶�
    eee=find(lpm(:,1,ii)==0,1,'first')-1;
    line(lpm(1:eee,1,ii),lpm(1:eee,2,ii),'linewidth',3,'color',[0 0 1]);
    text(opm(ii,1)+I_resize_Size/2,opm(ii,2)-30,[num2str(time_m(ii)*1000),'ms'],'color',[1 1 0],'fontsize',13);
end
for ii=1:size(opm,1) %�������ͷ����
    line([opm(ii,1)+1,opm(ii,1)+I_resize_Size,opm(ii,1)+I_resize_Size,opm(ii,1),opm(ii,1)+1],[opm(ii,2)+1,opm(ii,2)+1,opm(ii,2)+I_resize_Size,opm(ii,2)+I_resize_Size,opm(ii,2)+1],'color',[1 1 0])
    for jj=1:size(lpm,1) %���ÿ��������С����
    line([lpm(jj,1,ii)-unit_scale+1,lpm(jj,1,ii)-unit_scale+1,lpm(jj,1,ii),lpm(jj,1,ii),lpm(jj,1,ii)-unit_scale+1],[lpm(jj,2,ii)-floor(unit_scale/2),lpm(jj,2,ii)+floor(unit_scale/2),lpm(jj,2,ii)+floor(unit_scale/2),lpm(jj,2,ii)-floor(unit_scale/2),lpm(jj,2,ii)-floor(unit_scale/2)],'color',[0 1 0])
    end
end
%%%%������㡢�յ�����%%%%
sp=[spop_start(1)+x_start,spop_start(2)+y_start];
ep=point_mini+origin_big;
text(sp(1),sp(2),['������꣨',num2str(sp),'��'],'fontsize',15,'color',[1 0 1]);
text(ep(1),ep(2),['�յ�����(',num2str(ep),')'],'fontsize',15,'color',[0 0 1]);
%%%%�ۺ�������λ��%%%%
line([lpm(1,1,1)-floor(unit_scale/2),lpm(1,1,1)-floor(unit_scale/2),lpm(1,1,1)+floor(unit_scale/2),lpm(1,1,1)+floor(unit_scale/2),lpm(1,1,1)-floor(unit_scale/2)],[lpm(1,2,1)-floor(unit_scale/2),lpm(1,2,1)+floor(unit_scale/2),lpm(1,2,1)+floor(unit_scale/2),lpm(1,2,1)-floor(unit_scale/2),lpm(1,2,1)-floor(unit_scale/2)],'color',[1 0 1],'linewidth',5)
%%%%��ɫ�����յ�λ��%%%%
line([ep(1)-floor(unit_scale/2),ep(1)-floor(unit_scale/2),ep(1)+floor(unit_scale/2),ep(1)+floor(unit_scale/2),ep(1)-floor(unit_scale/2)],[ep(2)-floor(unit_scale/2),ep(2)+floor(unit_scale/2),ep(2)+floor(unit_scale/2),ep(2)-floor(unit_scale/2),ep(2)-floor(unit_scale/2)],'color',[0 0 1],'linewidth',5)
axis equal
t2=clock;
time_plot=etime(t2,t1);%��ͼ���ּ�ʱ����
title(['��ʼ�������ܺ�ʱ:',num2str(sum(time_int)*1000),'ms, ','���㲿���ܺ�ʱ:',num2str(sum(time_m)*1000),'ms, ','��ͼ�����ܺ�ʱ:',num2str(sum(time_plot)*1000),'ms'],'fontsize',15)


clc
disp('finished!');