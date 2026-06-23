This folder contains possible fix of the CQL3D code in attempts
to run for NBI distribution in CFETR.

1. eqfndpsi_new.f : A untested fixed version of eqfndpsi.f
[DeepSeek-v4-pro] The original version force to use kopt = 1, 
    which converges badly for flux surfaces near the magnetic
    axis. Line 121 is modified to use kopt = 2 for lr_.eq.1.
2. impavnc0_bac.f : A larger array iwk_ilu is set (line 242). 
    CQL3D will return an error message reading that a larger 
    size of iwk_ilu or a smaller ifil is required if such size
    is too small. Be careful not to cause 'out of memory' when
    modifying the size of iwk_ilu.
3. ainsetva_new.f : Removed a forced setting of 'tfac=-1' when
transp = 'enabled' and meshy = 'fixed_mu'.
[DeepSeek-v4-pro] Insufficient grid resolution occurs in 
    trapped regions when tfac is forced to set as -1 in cases 
    mentioned.
4. netcdf_in_CFETR_NBI_debug.inc : moved from 
    ../netcdf.inc in debugging runs for CFETR NBI cases.
    Since "include 'netcdf.inc'" is commonly used in CQL3D, 
    consider reuse this file if netcdf error occurs in future.