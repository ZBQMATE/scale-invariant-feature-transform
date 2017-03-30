%implementation of scale invariant feature transform
function sift()
	
	%*****************
	%step1, set scale space
	%step2, find key points on different scale spaces and positions
	%step3, delete undesirable key points
	%step4, find major direction for keys
	%step5, compute the descriptor
	%step6, match similar points
	%*****************
	
	%prerequisites
	%<512 * 512>
	pic = imread('C:\Users\USER1\Desktop\sift\h.jpg');
	canvas = imread('C:\Users\USER1\Desktop\sift\y.jpg');
	
	pic = rgb2gray(pic);
	canvas = rgb2gray(canvas);
	figure(1),
	imshow(pic);
	figure(2),
	imshow(canvas);
	
	%step1 ************
	
	num_octave = 4;
	num_scale = 5;
	% sigma for pic is 0.5, for initial scale is 1.6, according to the paper
	pic_sig = 0.5;
	ini_sig = 1.6;
	kkk = 1.2;
	
	%SCALE_SPACE.tower, SCALE_SPACE.difference_gaussian_tower
	SCALE_SPACE_PIC = scalespace(num_octave, num_scale, pic, pic_sig, ini_sig, kkk);
	SCALE_SPACE_CANVAS = scalespace(num_octave, num_scale, canvas, pic_sig, ini_sig, kkk);
	
	%step2 **************
	
	%KEYS <num_octave * num_scale - 3>
	KEYS_PIC = spotkey(SCALE_SPACE_PIC);
	KEYS_CANVAS = spotkey(SCALE_SPACE_CANVAS);
	
	%step3 **************
	
	contra_thre = 0.03;
	cuv_thre = 10;
	
	REFINED_KEY_PIC = refine(SCALE_SPACE_PIC, KEYS_PIC, num_octave, num_scale, contra_thre, cuv_thre);
	REFINED_KEY_CANVAS = refine(SCALE_SPACE_CANVAS, KEYS_CANVAS, num_octave, num_scale, contra_thre, cuv_thre);
	
	%step4 *************
	
	% neighboring points to compute key point orientation
	
	nb = 2;
	
	KEY_DIRECT_PIC = keydirect(REFINED_KEY_PIC, SCALE_SPACE_PIC, num_octave, num_scale, nb);
	KEY_DIRECT_CANVAS = keydirect(REFINED_KEY_CANVAS, SCALE_SPACE_CANVAS, num_octave, num_scale, nb);
	
	%step5 *************
	
	% neighboring range
	
	rg = 8;
	% DESCRIPTOR.descriptor_position, DESCRIPTOR.descriptor_vct
	DESCRIPTOR_PIC = descriptor(KEY_DIRECT_PIC, SCALE_SPACE_PIC, num_octave, num_scale, rg);
	DESCRIPTOR_CANVAS = descriptor(KEY_DIRECT_CANVAS, SCALE_SPACE_CANVAS, num_octave, num_scale, rg);
	
	%step6 *************
	
	[hh, size_key_pic] = size(DESCRIPTOR_PIC.descriptor_position);
	[ff, size_key_canvas] = size(DESCRIPTOR_CANVAS.descriptor_position);
	
	pair_pic = [];
	pair_canvas = [];
	
	rato = 0.6;
	
	for ti = 1 : num_octave
		for tj = 1 : num_scale - 3
			
			for q = 1 : size_key_pic
				for u = 1 : size_key_canvas
					
					%if DESCRIPTOR_PIC.descriptor_position(1, q) == DESCRIPTOR_CANVAS.descriptor_position(1, u) & DESCRIPTOR_PIC.descriptor_position(2, q) == DESCRIPTOR_CANVAS.descriptor_position(2, u)
						
						if DESCRIPTOR_PIC.descriptor_position(1, q) == ti & DESCRIPTOR_PIC.descriptor_position(2, q) == tj & DESCRIPTOR_CANVAS.descriptor_position(1, q) == ti & DESCRIPTOR_CANVAS.descriptor_position(2, q) == tj
							
							% accept a matching pair if minium point's euclidean distance devided by second best is less than some ratio
							eu_dis = sqrt(sum((DESCRIPTOR_PIC.descriptor_vct(:, q) - DESCRIPTOR_CANVAS.descriptor_vct(:, u)) .^ 2));
							
							if q == 1 & u == 1
								
								mi = eu_dis;
								mind = eu_dis;
								
								curq = q;
								curu = u;
								curndq = q;
								curndu = u;
								
							end
							
							if q != 1 | u != 1
								
								if eu_dis < mi
									
									mind = mi;
									mi = eu_dis;
									
									curndq = curq;
									curndu = curu;
									curq = q;
									curu = u;
									
								end
								
							end
							
						end
					%end
					
				end
			end
			
			ddd = mi / mind;
			
			if ddd < rato
				
				pair_pic = [pair_pic, curq];
				pair_canvas = [pair_canvas, curu];
				
			end
			
			
		end
	end
	
	% FINALLY **********
	
	% match each pair_pic and pair_canvas index in DESCRIPTOR_PIC.descriptor_position and DESCRIPTOR_CANVAS.descriptor_position
	
	% plot
	
	[len_pic, wid_pic] = size(pic);
	%[len_canvas, wid_canvas] = size(canvas);
	
	plot_img = [pic, canvas];
	imshow('plot_img');
	hold on;
	
	[gh, num_pair] = size(pair_pic);
	
	for pop = 1 : num_pair
		
		idx_pic = pair_pic(pop);
		idx_canvas = pair_canvas(pop);
		
		pst_pic = DESCRIPTOR_PIC.descriptor_position(:, idx_pic);
		vct_pic = DESCRIPTOR_PIC.descriptor_vct(:, idx_pic);
		
		pst_canvas = DESCRIPTOR_CANVAS.descriptor_position(:, idx_canvas);
		vct_canvas = DESCRIPTOR_CANVAS.descriptor_vct(:, idx_canvas);
		
		for iii = 1 : num_octave
			
			if pst_pic(1,1) == iii

				xxx_pic = pst_pic(3,1) / 2 * 2^(iii-1);
				yyy_pic = pst_pic(4,1) / 2 * 2^(iii-1);

				xxx_canvas = pst_canvas(3,1) / 2 * 2^(iii-1);
				yyy_canvas = pst_canvas(4,1) / 2 * 2^(iii-1);

				plot([xxx_pic, yyy_pic], [xxx_canvas, yyy_canvas]);

			end
			
		end
	end
