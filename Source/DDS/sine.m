x=[];
f=fopen('sine.txt','w');

for i=0:1024 
    x(i+1) = floor(127*sin(i*2*pi/1024)+127);
  %  fprintf('sine.txt', '%u',x(i+1));
    fprintf( f,'%d%c\n',x(i+1),',');
end

plot(x);