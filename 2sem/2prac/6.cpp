int gcd(int a, int b) {
    while (b != 0) {
        int temp = b;
        b = a % b;
        a = temp;
    }
    return a;
}

int euclid(int a, int b) {
    if (b == 0) {
        return (a, 1, 0);
    }
    else {
        auto [gsd, x1, y1] = euclid (b, a % b);
        int x = y1;
        int y = x1 - (a / b) * y1;
    }
    return (gsd, x, y);
}

int genereteKeys (int p, int q) {
    int n = p * q;
    int phi = (p - 1) * (q - 1);
    int e = 3;

    while (e < phi) {
        if (gcd2(e, phi) == 1) {
            break;
        }
        e++
    }

    int d = modInverse(e, phi);
    return (e, d, n);
}

