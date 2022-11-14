clc;
clear all; 
close all;

% Message
text = 'This is my academic thesis for uyuyhgbjuyhgndergrad and I ghvjhfvjhtgfvnghvhgv hgvhgvhgvam very happy to present this to you.';
length = strlength(text);
textAscii = uint8(text);
textReshaped = reshape(textAscii,[length,1]);
message = de2bi(textReshaped,8);
[r,l] = size(message);
messageTransposed = message';
messageInColumn = reshape(messageTransposed,[r*l,1]);

% Compression
block_size = 8;
mask_size = 8;
    
I11 = (imread('zelda.png'));
%imwrite(I11,'C:\Users\Ashraful Tauhid\Desktop\baaa.png');
I1 = im2double(I11); 
I1 = I1*255;    
no1 = (floor(size(I1,1)/(block_size)))*block_size;
no2 = (floor(size(I1,2)/block_size))*block_size;
I1 = imresize(I1,[no1,no2]);
     
    
I = I1;
Red = I(:,:,1);
T = dctmtx(block_size);
dct = @(block_struct) T* block_struct.data*T';
  
B1 = blockproc(I,[8,8],dct);
   
transformed = cat(1,B1);
    
%% table generation


quantization_table = ones(8,8);
quantization_table(1,1) = 16;quantization_table(1,2) = 11;quantization_table(1,3) = 10;quantization_table(1,4) = 16;
quantization_table(2,1) = 12;quantization_table(2,2) = 12;quantization_table(2,3) = 14;
quantization_table(3,1) = 14;quantization_table(3,2) = 13;
quantization_table(4,1) = 14;
    
    
%% quantization
quant = int64(zeros(size(I1,1),size(I1,1),1));
recon = double(zeros(size(I1,1),size(I1,1),1));
for k = 1:1
    for i = 1:block_size:size(I1,1)
        for j = 1:block_size:size(I1,2)
            for ii = 1:block_size
                for jj = 1:block_size
                    aa = B1(i+ii-1,j+jj-1,k);
                    quant(i+ii-1,j+jj-1,k) = (aa);
                    quant(i+ii-1,j+jj-1,k) = (aa/quantization_table(ii,jj));
                    
                end
            end
        end
    end
end

quantCopy = quant;
%% only dc value matrix
for x = 1:size(I1,1)/block_size
    for y = 1:size(I1,2)/block_size
        onlyDC(x,y) = quant((x*8)-7,(y*8)-7);
    end
end


dcMatrixTransposed = onlyDC';
dcMatrixReshaped = reshape(dcMatrixTransposed,[(size(I1,1)/block_size)*(size(I1,2)/block_size),1]);
dcMatrixBinary = de2bi(dcMatrixReshaped,8);
dcMatrixBinaryEmbedded = dcMatrixBinary;
for k = 1:r*l
    dcMatrixBinaryEmbedded(k,1) = messageInColumn(k,1);
end
dcMatrixDecimal = bi2de(dcMatrixBinaryEmbedded);
dcMatrixDecimalReshaped = reshape(dcMatrixDecimal,[(size(I1,1)/block_size),(size(I1,2)/block_size)]);
dcMatrixDecimalTransposed = dcMatrixDecimalReshaped';


for s = 1:(size(I1,1)/block_size)
    for t = 1:(size(I1,2)/block_size)
        quantCopy((s*8)-7,(t*8)-7) = dcMatrixDecimalTransposed(s,t);
    end
end

%% dequantisation
for k = 1:1
    for i = 1:block_size:size(I1,1)
        for j = 1:block_size:size(I1,2)
            for ii = 1:block_size
                for jj = 1:block_size                    
                    recon(i+ii-1,j+jj-1,k) = (quantCopy(i+ii-1,j+jj-1,k)*quantization_table(ii,jj));
                end
            end
        end
    end
end
    

%% reconstruction    
B1 = (recon(:,:,1));
invdct = @(block_struct) T' * block_struct.data * T;
RE1 = round(blockproc(B1,[block_size block_size],invdct));

I2 = cat(1,RE1);
I22 = uint8(I2);
%imtool(I11);
%imtool(I22);
difference = imsubtract(I11,I22);
%imtool(difference);
% figure
% subplot(2,1,1);
% imhist(I11);
% title('Cover')
% subplot(2,1,2);
% imhist(I22);
% title('Stego')

imwrite(I22,'C:\Users\Ashraful Tauhid\Desktop\Encrypted.jpg');
%% error
I1 = I1/255;
I2 = I2/255;
result1 = 0;
for i = 1:size(I1,1)
    for j = 1:size(I1,2)
        for k = size(I1,3)
            diff1 = (I1(i,j,k)-I2(i,j,k));
            result1 = result1+diff1*diff1;                
        end
     end
end
  
sizee = size(I2,1);    
MSE = result1/sizee;
PSNR = 10*log10(255*255/MSE);
MSE
PSNR
cor = corr2(I11,I22)