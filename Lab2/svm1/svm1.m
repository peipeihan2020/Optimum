clc;
clear;
close all;

%% Load Data

load TrainT1;

 y=TrainT1(:,3)';
 x=TrainT1(:,1:2)';

% x=[TrainT2(41:80,1:2)',TrainT2(109:160,1:2)'];
% y=[TrainT2(21:80,3)',TrainT2(109:160,3)'];

n=numel(y);

ClassA=find(y==1);
ClassB=find(y==-1);


%% Design SVM

C=10;

H=zeros(n,n);
for i=1:n
    for j=i:n
        H(i,j)=y(i)*y(j)*x(:,i)'*x(:,j);
        H(j,i)=H(i,j);
    end
end

f=-ones(n,1);

Aeq=y;
beq=0;

lb=zeros(n,1);
ub=C*ones(n,1);

Alg{1}='trust-region-reflective';
Alg{2}='interior-point-convex';
Alg{3}='active-set';

options=optimset('Algorithm',Alg{3},...
    'Display','off',...
    'MaxIter',20);

alpha=quadprog(H,f,[],[],Aeq,beq,lb,ub,[],options)';

AlmostZero=(abs(alpha)<max(abs(alpha))/1e5);

alpha(AlmostZero)=0;

S=find(alpha>0 & alpha<C);

w=0;
for i=S
    w=w+alpha(i)*y(i)*x(:,i);
end

b=mean(y(S)-w'*x(:,S));


%% Test SVM
%     load TestT1;
%     X=TestT1(:,1:2)';
%     target=TestT1(:,3);
%     cnt=0;
%     G=sign(w'*X+b);
%     for i=1:40
%         if G(i)==target(i);
%         cnt=cnt+1;
% 
%         end;
%     end
% 
%     classA=find(target==1);
%     classB=find(target==-1);


%% Plot Results

Line=@(x1,x2) w(1)*x1+w(2)*x2+b;
LineA=@(x1,x2) w(1)*x1+w(2)*x2+b+1;
LineB=@(x1,x2) w(1)*x1+w(2)*x2+b-1;

figure;
plot(x(1,ClassA),x(2,ClassA),'ro');
hold on;
plot(x(1,ClassB),x(2,ClassB),'bs');

% plot(X(1,classA),X(2,classA),'*');
% plot(X(1,classB),X(2,classB),'+'); 

plot(x(1,S),x(2,S),'ko','MarkerSize',12);
x1min=min(x(1,:));
x1max=max(x(1,:));
x2min=min(x(2,:));
x2max=max(x(2,:));

handle=ezplot(Line,[x1min x1max x2min x2max]);
set(handle,'Color','k','LineWidth',2);

handleA=ezplot(LineA,[x1min x1max x2min x2max]);
set(handleA,'Color','k','LineWidth',1,'LineStyle',':');

handleB=ezplot(LineB,[x1min x1max x2min x2max]);
set(handleB,'Color','k','LineWidth',1,'LineStyle',':');



legend('Class A','Class B');


