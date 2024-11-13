clearvars
clc

reader = BioformatsImage('../data/Data for MatLab Script/Control File_20241023_CAMKIID9_MOI10_noB_10min.nd2');
%reader = BioformatsImage('../data/Data for MatLab Script/Experimental File_20241023_CAMKIID9_MOI10_pB_10min.nd2');

outputDir = 'D:\Projects\ALMC Tickets\MirandaJuaros\Processed\20241113';

if ~exist(outputDir)
    mkdir(outputDir)
end

[~, fn] = fileparts(reader.filename);

%%

for iSeries = 1:reader.seriesCount

    reader.series = iSeries;
    Inucl = getPlane(reader, 1, 1, 1);

    nuclMask = imbinarize(Inucl);
    nuclMask = imopen(nuclMask, strel('disk', 3));
    nuclMask = bwareaopen(nuclMask, 50);

    dd = -bwdist(~nuclMask);
    dd(~nuclMask) = 0;
    dd = imhmin(dd, 1);

    L = watershed(dd);
    nuclMask(L == 0) = false;

    nuclMask = bwareaopen(nuclMask, 200);
    % imshowpair(Inucl, bwperim(nuclMask))

    %%

    Icell = getPlane(reader, 1, 2, 1);
    cellMask = imbinarize(Icell, 'adaptive');

    cellMask = imopen(cellMask, strel('disk', 3));
    cellMask = bwareaopen(cellMask, 300);

    cellMask = imfill(cellMask, 'holes');

    dd = -bwdist(~cellMask);
    dd(~cellMask) = 0;
    dd = imimposemin(dd, nuclMask);

    L = watershed(dd);
    cellMask(L == 0) = false;

    %%
    Iout = showoverlay(Icell, bwperim(cellMask));
    Iout = showoverlay(Iout, bwperim(nuclMask), 'Color', [1 1 0]);

    imwrite(Iout, fullfile(outputDir, [fn, 's_', int2str(iSeries), '_mask.tiff']), 'Compression', 'none');

    %% Quantify red channels in green positive cells only

    Ired = getPlane(reader, 1, 3, 1);

    data = regionprops(cellMask, Ired, 'MeanIntensity');

    storeData.Filename = fn;
    storeData.Intensities = cat(1, data.MeanIntensity);    
    storeData.CellMask = cellMask;
    storeData.NuclMask = nuclMask;    

end

save(fullfile(outputDir, [fn, '_data.mat']), 'storeData');





