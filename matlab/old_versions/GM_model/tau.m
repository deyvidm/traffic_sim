function t = tau(l, m, alpha, f_curr_speed, l_prev_pos, f_prev_pos)

    t = (l_prev_pos - f_prev_pos)^l/(alpha * f_curr_speed^m );

end