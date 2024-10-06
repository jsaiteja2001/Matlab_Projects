function [x]=Hourlytomonthly(y)
%it takes y as a matrix with 8640 elements and..
%calculate the average daily in 24 hours

for i=1:1:720
    a(i)=0;
end
l=1;
for i=1:720:8640
    for i=1:1:720
    a(i)=0;
    end
    for k=0:1:719
    a(k+1)=a(k+1)+y(i+k);
    end 
    c(l)=sum(a);
    l=l+1;
end
for i=1:1:12
x(i)=c(i)/720;
end
%--------------------------------------
end