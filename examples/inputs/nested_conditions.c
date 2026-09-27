int max(int a, int b)
{
    if (a > b)
    {
        return a;
    }
    else
    {
        return b;
    }
}

int main()
{
    int x;
    int y;
    int z;

    x = 20;
    y = 35;
    z = max(x, y);

    if (z > 25)
    {
        println(z);
    }
    else
    {
        println(x);
    }

    return 0;
}
