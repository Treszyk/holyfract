U0 DrawIt(CTask *t, CDC *dc)
{
    I64 cx = GR_WIDTH  >> 1;
    I64 cy = GR_HEIGHT >> 1;

    dc->color = WHITE;
    GrRect(dc, 0, 0, GR_WIDTH, GR_HEIGHT);

    dc->color = RED;
    GrRect(dc, cx-50, cy-50, 100, 100);

    GrPlot(dc, cx, cy);
}

U0 Main()
{
    SettingsPush;
    WinBorder;
    WinMax;
    DocClear;

    Fs->draw_it = &DrawIt;

    while (TRUE)
    {
        I64 ch = GetChar(, FALSE);
        if (ch == CH_ESC) break;
    }

    SettingsPop;
}

Main();
