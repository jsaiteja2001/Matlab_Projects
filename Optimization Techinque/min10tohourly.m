function [x]=min10tohourly(y)
%it takes y as a matrix with 52558 elements and..
%calculate the average hourly 

k=1;
for i=6:6:51840 
    x(k)=(y(i-5)+y(i-4)+y(i-3)+y(i-2)+y(i-1)+y(i))/6;
    k=k+1;
 end

end