function [x]=HourlytoDaily(y)
%it takes y as a matrix with 8640 elements and..
%calculate the average daily in 24 hours

for i=1:1:24
    a(i)=0;
end
for i=1:24:8640
    for k=0:1:23
    a(k+1)=a(k+1)+y(i+k);
    end       
end
for i=1:1:24
x(i)=a(i)/360;
end
%--------------------------------------
end