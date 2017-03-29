% compute the descriptor

%theta > -pi & theta <= -3*pi/4
%	eight_histo(1) = eight_histo(1) + mmm;

%theta > -3*pi/4 & theta <= -pi/2
%	eight_histo(2) = eight_histo(2) + mmm;

%theta > -pi/2 & theta <= -pi/4
%	eight_histo(3) = eight_histo(3) + mmm;

%theta > -pi/4 & theta <= 0
%	eight_histo(4) = eight_histo(4) + mmm;

%theta > 0 & theta <= pi/4
%	eight_histo(5) = eight_histo(5) + mmm;

%theta > pi/4 & theta <= pi/2
%	eight_histo(6) = eight_histo(6) + mmm;

%theta > pi/2 & theta <= 3*pi/4
%	eight_histo(7) = eight_histo(7) + mmm;

%theta > 3*pi/4 & theta <= pi
%	eight_histo(8) = eight_histo(8) + mmm;

function RST = descriptor(KEY_DIRECT, SCALE_SPACE, num_octave, num_scale, rg)
	
	% descriptor_position <4 * num_key> 4 represents octave, scale, dim1, dim2
	descriptor_position = [];
	% descriptor_vct <2*(rg^2) * num_key> 128 dim vector
	descriptor_vct = [];
	
	tower = SCALE_SPACE.tower;
	gaussian_para = fspecial('gaussian', [4, 4], 0.5);
	
	exu_rg = ceil(1.5 * rg);
	% count
	cnt = 1;
	eight_histo = zeros(8,1);
	
	for i = 1 : num_octave
		for j = 1 : num_scale - 3
			
			tower_board = tower{i, j + 1};
			dire_board = KEY_DIRECT{i, j};
			
			[len, wid] = size(tower_board);
			
			for da = 2 + exu_rg : len - exu_rg
				for db = 2 + exu_rg : wid - exu_rg
					
					if dire_board(da, db) != 0
						
						% ********* compute th rotate_mtx ***********
						
						% set 0 < theta < pi/4 (5) as standard direction
						if dire_board(da, db) == 1
							theta = pi;
						end
						
						if dire_board(da, db) == 2
							theta = 3 * pi / 4;
						end
						
						if dire_board(da, db) == 3
							theta = pi / 2;
						end
						
						if dire_board(da, db) == 4
							theta = pi / 4;
						end
						
						if dire_board(da, db) == 5
							theta = 0;
						end
						
						if dire_board(da, db) == 6
							theta = - pi / 4;
						end
						
						if dire_board(da, db) == 7
							theta = - pi / 2;
						end
						
						if dire_board(da, db) == 8
							theta = - 3 * pi / 4;
						end
						
						sin_theta = sin(theta);
						cos_theta = cos(theta);
						
						rotate_mtx = [cos_theta, -sin_theta; sin_theta, cos_theta];
						
						% ********* window **********
						
						xyxy = [];
						
						%xyxy_tgt = rotate_mtx * xyxy;
						
						for wa = -rg : rg
							for wb = -rg : rg
								xyxy = [xyxy;[wa,wb]];
							end
						end
						
						xyxy = transpose(xyxy);
						
						xyxy_tgt = rotate_mtx * xyxy;
						% xyxy_tgt <2*n>
						
						zj = ones(2, 4*rg*rg);
						zj = [da; db] .* zj;
						
						xyxy_tgt = xyxy_tgt .+ zj;
						
						% decompose xyxy_tgt
						map_x = zeros(rg*2, rg*2);
						map_y = zeros(rg*2, rg*2);
						
						for wi = 1 : rg * 2
							for wj = 1 : rg * 2
								
								map_x(wi, wj) = xyxy_tgt(1, wi*rg*2 + wj);
								map_y(wi, wj) = xyxy_tgt(2, wi*rg*2 + wj);
								
							end
						end
						
						% compute the descriptor
						
						vvvcccttt = zeros(2*(rg^2), 1);
						
						for na = 1 : 4
							for nb = 1 : 4
								
								for ma = 1 : rg / 2
									for mb = 1 : rg / 2
										
										xx = map_x((na-1)*rg+ma, (nb-1)*rg+mb);
										yy = map_y((na-1)*rg+ma, (nb-1)*rg+mb);
										
										% compute the gradient
										cur_mmm = sqrt((tower_board(xx+1,yy) - tower_board(xx-1,yy))^2 + (tower_board(xx,yy+1) - tower_board(xx,yy-1))^2);
										cur_theta = atan2((tower_board(xx,yy+1) - tower_board(xx,yy-1)) / (tower_board(xx+1,yy) - tower_board(xx-1,yy)));
										
										% divide into 8 histo
										
										if cur_theta > -pi & cur_theta <= -3*pi/4
											eight_histo(1) = eight_histo(1) + cur_mmm;
										end
										
										if cur_theta > -3*pi/4 & cur_theta <= -pi/2
											eight_histo(2) = eight_histo(2) + cur_mmm;
										end
										
										if cur_theta > -pi/2 & cur_theta <= -pi/4
											eight_histo(3) = eight_histo(3) + cur_mmm;
										end
										
										if cur_theta > -pi/4 & cur_theta <= 0
											eight_histo(4) = eight_histo(4) + cur_mmm;
										end
										
										if cur_theta > 0 & cur_theta <= pi/4
											eight_histo(5) = eight_histo(5) + cur_mmm;
										end
										
										if cur_theta > pi/4 & cur_theta <= pi/2
											eight_histo(6) = eight_histo(6) + cur_mmm;
										end
										
										if cur_theta > pi/2 & cur_theta <= 3*pi/4
											eight_histo(7) = eight_histo(7) + cur_mmm;
										end
										
										if cur_theta > 3*pi/4 & cur_theta < pi
											eight_histo(8) = eight_histo(8) + cur_mmm;
										end
										
										
									end
								end
								
								% na first
								vvvcccttt(((na-1)*4+nb-1)*8 : ((na-1)*4+nb)*8, 1) = eight_histo(:,1);
								eight_histo = zeros(8,1);
								
							end
						end
						
						%gaussian filter on vvvcccttt
						for jta = 1 : 4
							for jtb = 1 : 4
								
								parame = gaussian_para(jta, jtb);
								vvvcccttt(((jta-1)*4+jtb-1)*8 : (((jta-1)*4+jtb)*8), 1) = parame * vvvcccttt(((jta-1)*4+jtb-1)*8 : ((jta-1)*4+jtb)*8, 1);
								
							end
						end
						
						%save vvvcccttt pppooosss
						pppooosss = [i; j; da; db];
						descriptor_position = [descriptor_position, pppooosss];
						
						descriptor_vct = [descriptor_vct, vvvcccttt];
						
					end
					
				end
			end
			
		end
	end
	
	RST.descriptor_position = descriptor_position;
	RST.descriptor_vct = descriptor_vct;