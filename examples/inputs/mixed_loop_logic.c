int main()
{
    int i;
    int total;
    int temp;

    total = 0;
    i = 0;

    while (i < 6)
    {
        temp = i * 3;
        if (temp > 8)
        {
            total = total + temp;
        }
        else
        {
            total = total + 1;
        }
        i = i + 1;
    }

    println(total);
    return 0;
}
