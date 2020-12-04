function checkDependencies(app)
tmp = ver;
% Image Processing Toolbox
app.toolboxes.imagePro = ismember('Image Processing Toolbox',{tmp.Name});
if ~app.toolboxes.imagePro
    warning(['Missing Toolbox: Image Processing Toolbox is not installed.',...
        'While not necessary for operation, for best performance it is suggested to use the toolbox.'])
end

% Opimization Toolbox
app.toolboxes.Optimize = ismember('Optimization Toolbox',{tmp.Name});
if ~app.toolboxes.imagePro
    warning(['Missing Toolbox: Optimization Toolbox is not installed.',...
        'While not necessary for operation, for best performance it is suggested to use the toolbox.'])
end