



stock int clamp(int value, int min, int max)
{
	if (value > max)
	return max;
	if (value < min)
	return min;
	
	return value;
}
stock bool xor(bool a, bool b) {
	
	
	return (((!a)&&b)||((a)&&(!b)));
}
stock float floatclamp(float value, float minf, float maxf)
{
	if (value > maxf)
	return maxf;
	if (value < minf)
	return minf;
	
	return value;
}

stock int max(int x, int y)
{
	return x >= y ? x : y;
}

stock int min(int x, int y)
{
	return x <= y ? x : y;
}

stock float floatmax(float x, float y)
{
	return x >= y ? x : y;
}

stock float floatmin(float x, float y)
{
	return x <= y ? x : y;
}