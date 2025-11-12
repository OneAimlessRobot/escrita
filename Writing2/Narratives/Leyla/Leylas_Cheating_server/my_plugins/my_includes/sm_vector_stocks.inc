#if defined vector_stocks
	#endinput
#endif
#define vector_stocks
#include "sm_milks_defines.inc"

stock float angle_convert(float angle, bool false_for_degrees_to_radians_true_for_radians_to_degrees = true) {
	
	return (false_for_degrees_to_radians_true_for_radians_to_degrees ? (angle * (180.0 / MATH_PI)):(angle * (MATH_PI / 180.0)));
	
}

stock void vector_sub(float[] vec_b, float[] vec_a, float[] vec_result, int vec_size = 3) {
	
	
	for (int i = 0; i < vec_size; i++) {
		vec_result[i] = vec_b[i] - vec_a[i];
	}
	
}
stock void vector_add(float[] vec_b, float[] vec_a, float[] vec_result, int vec_size = 3) {
	
	
	for (int i = 0; i < vec_size; i++) {
		vec_result[i] = vec_b[i] + vec_a[i];
	}
	
}

stock void vector_mult(float[] vec_result, float[] vec_in, float num, int vec_size = 3) {
	
	
	for (int i = 0; i < vec_size; i++) {
		vec_result[i] = vec_in[i] * num;
	}
	
}
stock void vector_norm(float[] vec_result, float[] vec_in, int vec_size = 3) {
	
	float len = vector_len(vec_in, vec_size);
	float inv_len = 1.0 / len;
	vector_mult(vec_result, vec_in, inv_len, vec_size);
	
}
stock float dot_product(float[] input_a, float[] input_b, int vec_size = 3) {
	
	float result = 0.0;
	for (int i = 0; i < vec_size; i++) {
		
		result += input_a[i] * input_b[i];
		
	}
	return result;
	
}
stock float cross_product(float[] result, float[] input_a, float[] input_b, int vec_size = 3) {
	//[(a1 * b2 - a2 * b1), (a2 * b0 - a0 * b2), (a0 * b1 - a1 * b0)]
	
	result[0] = (input_a[1] * input_b[2]) - (input_a[2] * input_b[1]);
	result[1] = (input_a[2] * input_b[0]) - (input_a[0] * input_b[2]);
	result[2] = (input_a[0] * input_b[1]) - (input_a[1] * input_b[0]);
	
	float length = vector_len(result, 3);
	vector_norm(result, result, vec_size);
	return length;
	
}
stock void dir_vector_to_yaw_pitch_roll(float[] vec_result, float[] vec_in, int vec_size = 3) {
	
	if (vec_size > 3) {
		
		return;
	}
	vector_norm(vec_in, vec_in, vec_size);
	vec_result[0] = -1.0 * ArcSine(1.0 * (vec_in[2])) * (180.0 / MATH_PI);
	//vec_result[1] = ArcTangent2((1.0 * vec_result[0]),(1.0 * vec_result[2])) * (180.0 / MATH_PI);
	vec_result[1] = ArcTangent2((1.0 * vec_in[1]), (1.0 * vec_in[0])) * (180.0 / MATH_PI);
	//vec_result[1] = ArcCosine((1.0 * vec_in[1])) * (180.0 / MATH_PI);
	vec_result[2] = 0.0;
}
stock float vector_len(float[] vec_result, int vec_size = 3) {
	
	float result = 0.0;
	for (int i = 0; i < vec_size; i++) {
		result = result + (vec_result[i] * vec_result[i]);
	}
	float final_result = SquareRoot(result);
	return final_result;
}
stock void fill_vector(any[] vec_result, int vec_size = 3, any value) {
	
	Array_Fill(vec_result, vec_size, value, 0);
	
}
stock void print_vector(int client, const char[] vector_name, float vec_to_print[3]) {
	
	PrintToConsole(client, "Vector name:%s ", vector_name);
	PrintToConsole(client, "coords: (%0.2f, %0.2f, %0.2f)!!!!!", vec_to_print[0], vec_to_print[1], vec_to_print[2]);
	
	
} 
stock float angle_between_vectors_radians(float[] vec_a, float[] vec_b, int vec_size) {
	
	
	float dot_product_between_vecs = dot_product(vec_a, vec_b, vec_size);
	float vector_len_product = vector_len(vec_a, 3) * vector_len(vec_b, 3);
	float before_last = (dot_product_between_vecs / (vector_len_product));
	before_last = floatclamp(before_last, -1.0, 1.0);
	float angle_between_vec_a_and_vec_b = ArcCosine(before_last);
	return angle_between_vec_a_and_vec_b;
	
}
stock void rotate_vector3(float vec_result[3], float vec_input[3], float angle_to_rotate_by_in_radians) {
	
	/*
	float reference_vector[3] = { 1.0, 0.0, 0.0 };
	float original_angle = angle_between_vectors_radians(normalized_in_vec, reference_vector, 3);
	*/
	
	vec_result[0] = Cosine(angle_to_rotate_by_in_radians) * vec_input[0] - Sine(angle_to_rotate_by_in_radians) * vec_input[1];
	vec_result[1] = Sine(angle_to_rotate_by_in_radians) * vec_input[0] + Cosine(angle_to_rotate_by_in_radians) * vec_input[1];
	vec_result[2] = vec_input[2];
	
	
	
}