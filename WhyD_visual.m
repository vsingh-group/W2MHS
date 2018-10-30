%
function names = WhyD_visual(names, colorbar, gauss)
    % loads the grayscale probability map
    pmap = load_nii(fullfile(names.directory_path, names.seg_pmap));
    % converts to an 8-bit integer array
    if gauss > 0  % applies gaussian filter on the output image to blur it
        pmap = uint8(rescale(imgaussfilt3(pmap.img, gauss), 0, 256));
    else
        pmap = uint8(rescale(pmap.img, 0, 256));
    end
    % a binary mask selecting out the voxels without nonzero wmh probability
    wmh = repmat(pmap > 0, [1 1 1 3]);
    % the colored pmap output without the original image
    output = zeros([size(pmap) 3]);
    % colors the gray pmap
    output(wmh) = colorbar(pmap(pmap > 0),:);
    % loads the original neuroimage
    source = load_nii(fullfile(names.directory_path, names.source_bravo));
    % the colored pmap output combined with the original image
    output_merged = repmat(rescale(source.img), [1 1 1 3]);  
    % adds the pmap onto the original neuroimage
    output_merged(wmh) = output(wmh);
    % 511 - RGB96 is a storage data type for the generated nii heatmaps
    heatmap = make_nii(output_merged, [], [0 0 0], 511);
    names.heatmap = strrep(names.seg_pmap, 'pmap', 'heatmap');
    save_nii(heatmap, fullfile(names.directory_path, names.heatmap));    
    save(sprintf('%s/names_%s.mat', names.directory_path, names.folder_id), 'names');
end