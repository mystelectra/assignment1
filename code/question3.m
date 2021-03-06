
close all
clear all

L=200e-9;
W=100e-9;
n=10000; %change
nsteps =1000; %change

ang=randn(1,n)*2*pi;

m0=9.109382e-31; %electron mass
mn=0.26*m0;
T=300; %Kelvin
k=physconst('Boltzman');
d=1e-18;
tau_mn=0.2e-12; %seconds


vth = sqrt(k*T/mn);

%inititalize particle locations
x=rand(1,n)*L;
y=rand(1,n)*W;

% create a bunch of electrons not in the boxes
% box 1  190e-9<x<210e-9 60e-9<y<100e-9
% box 2  190e-9<x<210e-9 0<y<40e-9
Cxlow = 80e-9;
Cxhigh= 120e-9;
Cylow =40e-9;
Cyhigh=60e-9;
Ibox = (y>Cyhigh | y<Cylow) & x<Cxhigh & x>Cxlow;

countrestarts =0;
% no starting in boxes
for a = 1:n
while (x(a)<Cxhigh && x(a)>Cxlow && (y(a)>Cyhigh || y(a)<Cylow))
    x(a) = rand()*L;
    y(a) = rand()*W;
    countrestarts = countrestarts+1;
end
end

 
%initialize previous location as first location just to get the plot
%started
xp = x;
yp = y;
%initialize random velocities
vx=vth*rand(1,n);
vy=vth*rand(1,n);

dt=(L/vth)/100;

col=hsv(10); %vector of colours for particle trajectories
figure(7)
  for p = 1:10
        plot([x(p); xp(p)],[y(p); yp(p)],'color',col(p,:));  hold on
  end
    xlim([0 L])
    ylim([0 W])

%display boxes
line([Cxlow,Cxlow,Cxhigh,Cxhigh], [0,Cylow,Cylow,0], 'color', 'k');
line([Cxlow,Cxlow,Cxhigh,Cxhigh], [W,Cyhigh,Cyhigh,W], 'color', 'k');

%main timeloop
for i=1:nsteps

    xp=x;
    yp=y;

    dx=vx*dt;
    dy=vy*dt;
    
    %increment every particle over dt
    x=x+dx;
    y=y+dy;

    %xpath calc before boundary adjustment
    xpath=abs(x-xp); 

    %travelling restrictions (WALL)
     for a=1:n
       %no travelling through boxes
        if ( xp(a)<=Cxlow && x(a)>=Cxlow &&(y(a)>=Cyhigh ||y(a)<=Cylow))
            x(a)=Cxlow ;   
            vx(a)=-vx(a);
        elseif (xp(a)>=Cxhigh && x(a)<=Cxhigh&&(y(a)>=Cyhigh ||y(a)<=Cylow))
            x(a)=Cxhigh;           
            vx(a)=-vx(a);
        elseif (yp(a)<=Cyhigh && y(a)>=Cyhigh&&(x(a)>=Cxlow && x(a)<=Cxhigh))
            y(a) = Cyhigh;    
            vy(a) = -vy(a);
        elseif (yp(a)>=Cylow && y(a)<=Cylow&&(x(a)>=Cxlow && x(a)<=Cxhigh))
              y(a) = Cylow;   
            vy(a) = -vy(a);
        end
        
        %periodic boundaries at x=0 and x=L
         if (xp(a)< L && x(a)>=L)
            x(a)=x(a)-L;
            xp(a)=xp(a)-L;
         elseif (xp(a)< 0 && x(a)<0)
            x(a) = x(a)+L;
            xp(a)=xp(a)+L;
         end
         
        %specular boundaries at y=0 and y=W
        if (y(a)>=W || y(a)<=0)
            vy(a) = -vy(a);
        elseif y(a)<=0
          vy(a) = -vy(a);
        end
     end %end travelling restrictions loop
     
    %scattering
    pscat=1-exp(-dt/tau_mn);
    scatCount= 0;
    
    for bb=1:n
        if (pscat > rand())
            vx(bb)=vth*randn()/sqrt(2);
            vy(bb)=vth*randn()/sqrt(2);
            scatCount = scatCount+1;
        end
    end

     %ypath calc after boundary adjustment
    ypath=abs(y-yp); 
    
    %calculate path - not sure if this is right
    path = sqrt(xpath.*xpath + ypath.*ypath);    
    
%     plot(x,y,'o');hold on
  figure (7)
    %plot trajectories 
    for p = 1:10
        plot([x(p); xp(p)],[y(p); yp(p)],'color',col(p,:));  hold on
    end
    xlim([0 L])
    ylim([0 W])
    title ('Monte Carlo Simulation of Electron Trajectories with Bottleneck')
    pause(0.01);

      
end

delta = 5e-9;
counta=0;
countelectrons=0;
Nmap = zeros(L/delta,W/delta);
Vmap = zeros(L/delta,W/delta);
Tmap = zeros(L/delta,W/delta);

%populate density maps
for  aa = delta:delta:L
    counta=counta+1;
    countb=0;
    for bb=delta:delta:W
        countb=countb+1;
        for cc=1:n
            %Populate Electron Density Map
            if (x(cc)<(counta*delta) & x(cc)>=((counta-1)*delta) & y(cc)<(countb*delta) & y(cc)>=((countb-1)*delta))
              Nmap(counta,countb) = Nmap(counta,countb)+1;
              Vmap(counta,countb) = Vmap(counta,countb)+sqrt(vx(cc)*vx(cc)+vy(cc)*vy(cc));
              map(counta,countb)=Vmap(counta,countb)/Nmap(counta,countb);
              Tmap(counta,countb) = map(counta,countb)*map(counta,countb)*mn/k;
              countelectrons = countelectrons +1;
            elseif(x(cc)== L)
                Nmap(counta,countb) = Nmap(counta,countb)+1;
                Vmap(counta,countb) = Vmap(counta,countb)+sqrt(vx(cc)*vx(cc)+vy(cc)*vy(cc));
                map(counta,countb)=Vmap(counta,countb)/Nmap(counta,countb);
               Tmap(counta,countb) = map(counta,countb)*map(counta,countb)*mn/k;
                countelectrons = countelectrons +1;  
             elseif(y(cc)==W)
                Nmap(counta,countb) = Nmap(counta,countb)+1;
                Vmap(counta,countb) = Vmap(counta,countb)+sqrt(vx(cc)*vx(cc)+vy(cc)*vy(cc));
                map(counta,countb)=Vmap(counta,countb)/Nmap(counta,countb);
               Tmap(counta,countb) = map(counta,countb)*map(counta,countb)*mn/k;
                countelectrons = countelectrons +1; 
            elseif(x(cc)== L & y(cc)==W)
                Nmap(counta,countb) = Nmap(counta,countb)+1;
                Vmap(counta,countb) = Vmap(counta,countb)+sqrt(vx(cc)*vx(cc)+vy(cc)*vy(cc));
                map(counta,countb)=Vmap(counta,countb)/Nmap(counta,countb);
               Tmap(counta,countb) = map(counta,countb)*map(counta,countb)*mn/k;
                countelectrons = countelectrons +1;
            end            
        end
    end
end

for  dd = 1:L/delta
    for ee=1:W/delta
        if Tmap(dd,ee)== 0
            Tmap(dd,ee) = 300;
        end            
    end
end

 figure(8)
surf(Nmap)
colormap('parula')
colorbar
shading interp;

figure (9)
surf(Tmap)
h=flipud(hsv);
colormap(h)
caxis([200 800])
colorbar
shading interp;



 
