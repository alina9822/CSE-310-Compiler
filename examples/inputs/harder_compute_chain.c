int compute(int x, int y)
{
    int z;
    z = x * y + 10;
    if (z > 50)
    {
        return z - 5;
    }
    else
    {
        return z + 5;
    }
}

int main()
{
    int a;
    int b;
    int result;

    a = 6;
    b = 7;
    result = compute(a, b);

    if (result > 40)
    {
        println(result);
    }
    else
    {
        println(a + b);
    }

    return 0;
}
