int add(int a, int b)
{
    return a + b;
}

int main()
{
    int i;
    int total;

    total = 0;
    i = 0;

    while (i < 5)
    {
        total = total + add(i, 2);
        i = i + 1;
    }

    println(total);
    return 0;
}
