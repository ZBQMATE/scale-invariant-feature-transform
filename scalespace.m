%step1, set scale space
function RST = scalespace(num_octave, num_scale, pic, pic_sig, ini_sig, kkk)
	
	tower = cell(num_octave, num_scale);
	difference_gaussian_tower = cell(num_octave, num_scale-1);
	
	gaus_pic = imgaussfilt(pic, pic_sig);
	
	tower{1, 1} = imresize(gaus_pic, 2);
	
	for i = 1 : num_octave
	
		sigma = ini_sig;
		
		for j = 2 : num_scale
			
			tower{i, j} = imgaussfilt(tower{i, j-1}, sigma);
			difference_gaussian_tower{i, j-1} = tower{i, j-1} - tower{i, j};
			
			sigma = sigma * kkk;
			
		end
		
		if i < num_octave
			tower{i+1, 1} = imresize(tower{i, 1}, 0.5);
		end
		
	end
	
	RST.tower = tower;
	RST.difference_gaussian_tower = difference_gaussian_tower;