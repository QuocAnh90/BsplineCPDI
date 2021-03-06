function [N,dN,CONNECT,spElems,mspoints,NODES] = Compute_Interpolator_CPDI(spCount,cellCount,x_sp,le,NN,LOC,r1_sp,r2_sp,V_sp)

 spElems_corner = zeros(spCount,4);
 spElems        = zeros(spCount,1);
 CONNECT        = cell(spCount,1);
 NODES          = zeros(spCount,1);
 N              = cell(spCount,1);
 dN             = cell(spCount,1);
 mspoints       = cell(cellCount,1);
 
x_corner1 = x_sp - r1_sp - r2_sp;
x_corner2 = x_sp + r1_sp - r2_sp;
x_corner3 = x_sp + r1_sp + r2_sp;
x_corner4 = x_sp - r1_sp + r2_sp;


 for sp = 1:spCount
 spElems(sp) = ceil(x_sp(sp,1)/le(1))+(NN(1)-1)*(fix(x_sp(sp,2)/le(2)));   % compute vector store index elements                           
 spElems_corner(sp,1) = ceil(x_corner1(sp,1)/le(1))+(NN(1)-1)*(fix(x_corner1(sp,2)/le(2)));                        
 spElems_corner(sp,2) = ceil(x_corner2(sp,1)/le(1))+(NN(1)-1)*(fix(x_corner2(sp,2)/le(2)));                        
 spElems_corner(sp,3) = ceil(x_corner3(sp,1)/le(1))+(NN(1)-1)*(fix(x_corner3(sp,2)/le(2)));
 spElems_corner(sp,4) = ceil(x_corner4(sp,1)/le(1))+(NN(1)-1)*(fix(x_corner4(sp,2)/le(2)));

 CONNECT_TEMP = zeros(1,16);
 
 CONNECT_TEMP(1)  = spElems_corner(sp,1) + floor(spElems_corner(sp,1)/(NN(1)-1));
 CONNECT_TEMP(2)  = CONNECT_TEMP(1) + 1;
 CONNECT_TEMP(3)  = CONNECT_TEMP(2) + NN(1);
 CONNECT_TEMP(4)  = CONNECT_TEMP(1) + NN(1);
 
 CONNECT_TEMP(5)  = spElems_corner(sp,2) + floor(spElems_corner(sp,2)/(NN(1)-1));
 CONNECT_TEMP(6)  = CONNECT_TEMP(5) + 1;
 CONNECT_TEMP(7)  = CONNECT_TEMP(6) + NN(1);
 CONNECT_TEMP(8)  = CONNECT_TEMP(5) + NN(1); 

 CONNECT_TEMP(9)  = spElems_corner(sp,3) + floor(spElems_corner(sp,3)/(NN(1)-1));
 CONNECT_TEMP(10) = CONNECT_TEMP(9) + 1;
 CONNECT_TEMP(11) = CONNECT_TEMP(10) + NN(1);
 CONNECT_TEMP(12) = CONNECT_TEMP(9) + NN(1); 

 CONNECT_TEMP(13) = spElems_corner(sp,4) + floor(spElems_corner(sp,4)/(NN(1)-1));
 CONNECT_TEMP(14) = CONNECT_TEMP(13) + 1;
 CONNECT_TEMP(15) = CONNECT_TEMP(14) + NN(1);
 CONNECT_TEMP(16) = CONNECT_TEMP(13) + NN(1);

 CONNECT{sp}=unique(CONNECT_TEMP);    % Store nodes interacting with corners
 NODES(sp)=length(CONNECT{sp});         % Store number of interacting nodes
 
 N1 = zeros(1,NODES(sp));   % Shape function of corner 1 for 16 nodes
 N2 = zeros(1,NODES(sp));
 N3 = zeros(1,NODES(sp));
 N4 = zeros(1,NODES(sp));
 N_local = zeros(1,NODES(sp));
 
 for i=1:NODES(sp)
    [N1(i),~,~] = linearshape(x_corner1(sp,:),LOC(CONNECT{sp}(i),:),le(1,1),le(1,2));
    [N2(i),~,~] = linearshape(x_corner2(sp,:),LOC(CONNECT{sp}(i),:),le(1,1),le(1,2));
    [N3(i),~,~] = linearshape(x_corner3(sp,:),LOC(CONNECT{sp}(i),:),le(1,1),le(1,2));
    [N4(i),~,~] = linearshape(x_corner4(sp,:),LOC(CONNECT{sp}(i),:),le(1,1),le(1,2));
    N_local(i)  = 0.25*(N1(i)+N2(i)+N3(i)+N4(i));
 end
 
 N{sp} = N_local;
 
 % Build matrix of gradient of shape function 
 w1 = [r1_sp(sp,2)-r2_sp(sp,2) r2_sp(sp,1)-r1_sp(sp,1)];
 w2 = [r1_sp(sp,2)+r2_sp(sp,2) -r2_sp(sp,1)-r1_sp(sp,1)];
 
 for i=1:NODES(sp)      
dN{sp}(1,i)     = 1/V_sp(sp)*((N1(i)-N3(i))*w1(1) + (N2(i)-N4(i))*w2(1));
dN{sp}(2,i)     = 1/V_sp(sp)*((N1(i)-N3(i))*w1(2) + (N2(i)-N4(i))*w2(2));
 end
 end
 
 for c =1:cellCount
     id_sp = find(spElems==c);
     mspoints{c}=id_sp;
 end