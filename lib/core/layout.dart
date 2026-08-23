/// Width at which HomeShell uses a persistent side nav instead of a drawer.
const double kDesktopNavBreakpoint = 800;

bool useDesktopNav(double width) => width >= kDesktopNavBreakpoint;
