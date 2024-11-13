clearvars
clc

dataDir = 'D:\Projects\ALMC Tickets\MirandaJuaros\Processed\20241113';
control = load(fullfile(dataDir, 'Control File_20241023_CAMKIID9_MOI10_noB_10min_data.mat'));
exp = load(fullfile(dataDir, 'Experimental File_20241023_CAMKIID9_MOI10_pB_10min_data.mat'));

%Get data into correct format
controlIntensities = [];
for ii = 1:numel(control.storeData)
    controlIntensities = [controlIntensities; control.storeData.Intensities];
end

expIntensities = [];
for ii = 1:numel(control.storeData)
    expIntensities = [expIntensities; exp.storeData.Intensities];
end

data = [controlIntensities; expIntensities];

groups = [repmat({'Control'}, numel(controlIntensities), 1); ...
    repmat({'Exp'}, numel(expIntensities), 1)];

% boxplot(data, groups)

[p, tbl, stats] = anova1(data, groups);