function net = cnnff(net, x)
    n = numel(net.layers);
    net.layers{1}.a{1} = x;
    inputmaps = 1;

    for l = 2 : n   %  for each layer
        if strcmp(net.layers{l}.type, 'c')
            %  !!below can probably be handled by insane matrix operations
            for j = 1 : net.layers{l}.outputmaps   %  for each output map
                %  create temp output map
                z = zeros(size(net.layers{l - 1}.a{1}) - [net.layers{l}.kernelsize - 1 net.layers{l}.kernelsize - 1 0]);  % imageDim-patchDim+1 * imageDim-patchDim+1, ����r-a+1��*(c-b+1)��patch��Ϊ����ˣ���Ȩ�ع���
                for i = 1 : inputmaps   %  for each input map                                %��ʵfor each input map���Ƕ�ÿһ��ͨ�������ÿһ��ͨ�������ӵõ����ս��
                    %  convolve with corresponding kernel and add to temp output map
                    % ����a{i}��k{i}{j}�����˵��a{i}����һ��Ԫ�أ�����һ��ƽ��
                    z = z + convn(net.layers{l - 1}.a{i}, net.layers{l}.k{i}{j}, 'valid');   %����k{i}{j}���Ǿ���ˣ�5*5�ľ��󣩣���cnnsetup.m��ʼ���õ�������Ȩ��Wij����cnnConvolve.m UFlDl�̳�
                end
                %  add bias, pass through nonlinearity
                net.layers{l}.a{j} = sigm(z + net.layers{l}.b{j});                           %֮��, apply the sigmoid function to get the hidden activation���õ�a{j}
            end
            %  set number of input maps to this layers number of outputmaps
            inputmaps = net.layers{l}.outputmaps;
        elseif strcmp(net.layers{l}.type, 's')
            %  downsample
            for j = 1 : inputmaps
                z = convn(net.layers{l - 1}.a{j}, ones(net.layers{l}.scale) / (net.layers{l}.scale ^ 2), 'valid');   %  !! replace with variable
                net.layers{l}.a{j} = z(1 : net.layers{l}.scale : end, 1 : net.layers{l}.scale : end, :);
            end
        end
    end

    %  concatenate all end layer feature maps into vector
    net.fv = [];
    for j = 1 : numel(net.layers{n}.a)   %end layer ������feature map
        sa = size(net.layers{n}.a{j});
        net.fv = [net.fv; reshape(net.layers{n}.a{j}, sa(1) * sa(2), sa(3))];  %net.fv��������feature map������ͬ
    end
    %  feedforward into output perceptrons
    net.o = sigm(net.ffW * net.fv + repmat(net.ffb, 1, size(net.fv, 2)));

end
