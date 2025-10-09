#define S_CX (GR_WIDTH >> 1)
#define S_CY (GR_HEIGHT >> 1)
F64 M_CX = -0.5, M_CY = 0; // these are math plane coords, the ones above are for the screen

I64 max_iter = 128
F64 scale = 3.0 / GR_WIDTH;

U0 ScreenToComplex(I64 x, I64 y, F64 *re, F64 *im)
{
    *re = M_CX + (x - S_CX) * scale;
    *im = M_CY + (y - S_CY) * scale;
}

I64 MandelIter(F64 re, F64 im, I64 max_iter)
{
    F64 zr = 0.0, zi = 0.0;
    F64 zr2 = 0.0, zi2 = 0.0, t = 0.0;

    for (I64 i = 0; i < max_iter; i++)
    {
        zr2 = zr * zr;
        zi2 = zi * zi;

        if (zr2 + zi2 > 4.0)
            return i;

        t  = zr * zi;
        zi = 2.0 * t + im;
        zr = zr2 - zi2 + re;
    }

    return max_iter;
}

U32 MandelColor(I64 iter, I64 max_iter)
{
    if (iter >= max_iter || iter <= 4) return 0;

    F64 t = iter(F64) / max_iter(F64);
    t = Sqrt(t);
    I64 idx = 1 + (t * 14.0)(I64);

    if (idx > 15) idx = 15;
    return (iter >> 3) & (COLORS_NUM - 1);
}

U0 RenderMandel(CDC *dc)
{
    F64 re, im;
    I64 x, y, iter;

    for (y = 0; y < GR_HEIGHT; y++)
    {
        for (x = 0; x < GR_WIDTH; x++)
        {
            ScreenToComplex(x, y, &re, &im);
            iter = MandelIter(re, im, max_iter);
            dc->color = MandelColor(iter, max_iter);
            GrPlot(dc, x, y);
        }
    }
}

U0 ApplyFractalPalette()
{
    I64 i;
    CBGR48 bgr;

    GrPaletteColorSet(0, 0x000000);
    for (i = 1; i < COLORS_NUM; i++)
    {
        I64 v = (0xFFFF * i) / (COLORS_NUM - 1);
        bgr.r = v >> 1;
        bgr.g = 0;
        bgr.b = v;

        GrPaletteColorSet(i, bgr);
    }
}

U0 Main()
{
    CDC *dc = DCAlias;
    SettingsPush;
    ApplyFractalPalette;
    WinMax;
    WinBorder;
    DocCursor;
    DocClear;
    AutoComplete;
    DCFill(dc);

    // seahorse valley quickstart
    // M_CX = -0.74364388703715;
    // M_CY = 0.13182590420533;
    // scale = 0.006 / GR_WIDTH;

    RenderMandel(dc);

    I64 ch, sc;

    while (TRUE)
    {
        if (ScanKey(&ch, &sc))
        {
            if (ch == CH_ESC)
                break;

            if (ch == 0)
            {
                switch (sc.u8[0])
                {
                    case SC_CURSOR_UP:    M_CY -= 32 * scale * 0.5; break;
                    case SC_CURSOR_DOWN:  M_CY += 32 * scale * 0.5; break;
                    case SC_CURSOR_LEFT:  M_CX -= 32 * scale * 0.5; break;
                    case SC_CURSOR_RIGHT: M_CX += 32 * scale * 0.5; break;
                }
            }
            else
            {
                if (ch == 'a') scale *= 0.5;
                if (ch == 'd') scale *= 2.0;
                if (ch == 'm') max_iter = 1024;
                if (ch == 'n') max_iter = 128;
            }

            RenderMandel(dc);

            // flush buffered keys, couldn't find the correct command so I'm doing this
            while (ScanKey(&ch, &sc)) { }
        }

        Sleep(50);
    }

    DCFill(dc);
    DCDel(dc);
    SettingsPop;
}

Main;
