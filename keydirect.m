% compute key direct for each key point
function RST = keydirect(REFINED_KEY, SCALE_SPACE, num_octave, num_scale, nb)
	
	%<num_octave * num_scale>
	tower = SCALE_SPACE.tower;
	
	%<num_octave * num_scale - 3>
	key_dir = cell(num_octave, num_scale - 3);
	
	this_window_mmm = zeros(2*nb+1, 2*nb+1);
	this_window_theta = zeros(2*nb+1, 2*nb+1);
	
	eight_histo = zeros(8,1);
	
	gaussian_para = fspecial('gaussian', [2*nb+1, 2*nb+1], 0.5);
	
	for i = 1 : num_octave
		for j = 1 : num_scale - 3
			
			key_board = REFINED_KEY{i, j};
			% warning
			tower_board = tower{i, j + 1};
			[len, wid] = size(key_board);
			key_dir_board = zeros(len, wid);
			
			for da = 2 + nb : len - 1 - nb
				for db = 2 + nb : wid - 1 - nb
					
					if key_board(da, db) != 0
						
						%compute the main direction using neiboring nb points
						for wa = da - nb : da + nb
							for wb = db - nb : db + nb
								
								mmm = sqrt((tower_board(wa+1,wb) - tower_board(wa-1,wb))^2 + (tower_board(wa,wb+1) - tower_board(wa,wb-1))^2);
								theta = atan2((tower_board(wa,wb+1) - tower_board(wa,wb-1)) / (tower_board(wa+1,wb) - tower_board(wa-1,wb)));
								
								% gaussian weights
								mmm = mmm * gaussian_para(wa-da+nb+1, wb-db+nb+1);
								
								this_window_mmm(wa-da+nb+1, wb-db+nb+1) = mmm;
								this_window_theta(wa-da+nb+1, wb-db+nb+1) = theta;
								
								
								%divide into eight main directions
								
								if theta > -pi & theta <= -3*pi/4
									eight_histo(1) = eight_histo(1) + mmm;
								end
								
								if theta > -3*pi/4 & theta <= -pi/2
									eight_histo(2) = eight_histo(2) + mmm;
								end
								
								if theta > -pi/2 & theta <= -pi/4
									eight_histo(3) = eight_histo(3) + mmm;
								end
								
								if theta > -pi/4 & theta <= 0
									eight_histo(4) = eight_histo(4) + mmm;
								end
								
								if theta > 0 & theta <= pi/4
									eight_histo(5) = eight_histo(5) + mmm;
								end
								
								if theta > pi/4 & theta <= pi/2
									eight_histo(6) = eight_histo(6) + mmm;
								end
								
								if theta > pi/2 & theta <= 3*pi/4
									eight_histo(7) = eight_histo(7) + mmm;
								end
								
								if theta > 3*pi/4 & theta <= pi
									eight_histo(8) = eight_histo(8) + mmm;
								end
								
							end
						end
						
						[max_histo, max_histo_idx] = max(eight_histo);
						eight_histo = zeros(8, 1);
						
						key_dir_board(da, db) = max_histo_idx;
						
					end
					
				end
			end
			
			% save to the tower
			
			key_dir{i, j} = key_dir_board;
			
		end
	end
	
	RST = key_dir;