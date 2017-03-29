%step3, delete undesirable key points
function RST = refine(SCALE_SPACE, KEYS, num_octave, num_scale, contra_thre, cuv_thre)
	
	difference_gaussian_tower = SCALE_SPACE.difference_gaussian_tower;
	
	% KEYS is a tower with values of 0, -100, 100
	
	[sss, hhh] = size(KEYS);
	new_key = cell(sss, hhh);
	
	for i = 1 : num_octave
		for j = 1 : num_scale - 3
			
			this_board = KEYS{i, j};
			dgt_board = difference_gaussian_tower{i, j};
			[len, wid] = size(this_board);
			
			for c = 2 : len - 1
				for k = 2 : wid - 1
					
					if this_board(c,k) != 0
						
						% low contraction
						if abs(dgt_board(c,k)) < contra_thre
							
							this_board(c, k) = 0;
							
						end
						
						% responded edge
						else
							
							%compute 2nd derivative
							dxx = this_board(c-1,k) + this_board(c+1,k) - 2*this_board(c,k);
							
							dyy = this_board(c,k-1) + this_board(c,k+1) - 2*this_board(c,k);
							
							dxy = this_board(c-1,k-1) + this_board(c+1,k+1) - this_board(c-1,k+1) - this_board(c+1,k-1);
							
							tr = dxx + dyy;
							det = dxx * dyy - dxy * dxy;
							
							ggg = tr * tr / det;
							
							if ggg > (cuv_thre+1)*(cuv_thre+1)/cuv_thre
								
								this_board(c, k) = 0;
								
							end
							
							
						end
						
					end
					
				end
			end
			
			new_key{i, j} = this_board;
			%$$
		end
	end
	
	RST = new_key;