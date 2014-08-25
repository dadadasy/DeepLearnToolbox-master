function net = cnnsetup(net, x, y)
    %assert(~isOctave() || compare_versions(OCTAVE_VERSION, '3.8.0', '>='), ['Octave 3.8.0 or greater is required for CNNs as there is a bug in convolution in previous versions. See http://savannah.gnu.org/bugs/?39314. Your version is ' OCTAVE_VERSION]);
    inputmaps = 1;
    mapsize = size(squeeze(x(:, :, 1)));

    for l = 1 : numel(net.layers)   %  layer
        if strcmp(net.layers{l}.type, 's')    % pooling layer
            mapsize = mapsize / net.layers{l}.scale;
            assert(all(floor(mapsize)==mapsize), ['Layer ' num2str(l) ' size must be integer. Actual: ' num2str(mapsize)]);
            for j = 1 : inputmaps
                net.layers{l}.b{j} = 0;
            end
        end
        if strcmp(net.layers{l}.type, 'c')    % convolution layer
            mapsize = mapsize - net.layers{l}.kernelsize + 1;
            fan_out = net.layers{l}.outputmaps * net.layers{l}.kernelsize ^ 2;
            for j = 1 : net.layers{l}.outputmaps  %  output map
                fan_in = inputmaps * net.layers{l}.kernelsize ^ 2;
                for i = 1 : inputmaps  %  input map
                    net.layers{l}.k{i}{j} = (rand(net.layers{l}.kernelsize) - 0.5) * 2 * sqrt(6 / (fan_in + fan_out));
                end
                net.layers{l}.b{j} = 0;
            end
            inputmaps = net.layers{l}.outputmaps;
        end
    end
    % 'onum' is the number of labels, that's why it is calculated using size(y, 1). If you have 20 labels so the output of the network will be 20 neurons.
    % 'fvnum' is the number of output neurons at the last layer, the layer just before the output layer.
    % 'ffb' is the biases of the output neurons.
    % 'ffW' is the weights between the last layer and the output neurons. Note that the last layer is fully connected to the output layer, that's why the size of the weights is (onum * fvnum)
    fvnum = prod(mapsize) * inputmaps;
    onum = size(y, 1);

    net.ffb = zeros(onum, 1);
    net.ffW = (rand(onum, fvnum) - 0.5) * 2 * sqrt(6 / (onum + fvnum));
end

%�ҵ�ע�� 2014/03/04
% a[j]�Ǽ���ֵ, d[j]�ǲв�,������, j��l���j��feature map, feature map��ͼ�������˾��������ȡ������ͼ��
% a[j]���������紫ͳ�����һ��ĵ�j��Ԫ�أ����ǵ�j��feature map���е�Ԫ��, �����Ѿ�������sigmoid������net.layers{1}.a{1} = x,
% net.layer{1}���������һ�㣬������㣬net.layers{1}.a{1}��ͼ��ĳ�ʼֵ����Ϊ�����ֻ��һ��feature
% map��������a{1}
% k{i}{j}�ǵ�l���i��feature map���ӵ�l+1���j��feature map�ľ���ˣ�Ȩֵ����
% ÿһ��k{i}{j}����һ��5*5�ľ��������ʼ��rand(5)
% net.layers{l - 1}.a{1}��һ��3ά���� ���һά��������
% net.layers{l}.d{j} ��һ��3ά����   ���� d(:,:,1)=[m*n]�� d(:,:,2)=[m*n],
% d(:,:,k)=[m*n], ��dΪһ�� m*n*k ��3ά����   length(size(d))=3
% d(:,:,k)=[m*n], ��dΪһ�� m*n*k ��3ά����   length(size(d))=3