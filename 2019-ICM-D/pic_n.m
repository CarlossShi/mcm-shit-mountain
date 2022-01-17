function [pic_n]=pic_n(pic,f)  %从大图中抽取第f楼的图
pic_n=pic((1:684)+684*(5-f),:,:);
end