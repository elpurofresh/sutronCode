Overview
--------
The files in this directory are used to upgrade the Xpert2 firmware. Files are 
provided to upgrade the application, kernel, loader, and micro-monitor. The 
procedure described below upgrades all components. 

   !!!!!!!!!!!!!!!!!!!!!!!!!!! IMPORTANT NOTES !!!!!!!!!!!!!!!!!!!!!!!!!!
   !
   !  NOTE 1: WHEN UPGRADING TO v3.8 OR HIGHER FROM A LOWER VERSION, YOU 
   !  MUST UPGRADE THE LOADER!!! THE PROCEDURE DESCRIBED WILL UPGRADE 
   !  THE LOADER. 
   !
   !  NOTE 2: DO NOT DOWNGRADE TO v3.7 OR LOWER FROM A VERSION HIGHER 
   !  WITHOUT OFFLOADING YOUR DATA FIRST! DOWNGRADING TO v3.7 OR LOWER 
   !  FROM A HIGHER VERSION WILL RESULT IN A LOSS OF DATA ON FLASH DISK!
   !
   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

How to Upgrade
--------------
1. Connect your PC to the Xpert2 using a direct serial cable connection to COM1 
   of the Xpert2. To use ethernet, (much faster than serial), connect the 
   Xpert2/9210B to a DHCP-enabled network, in addition to the serial cable 
   attached to COM1, and specify "/LAN" as a command line argument to XTerm. 
2. Start XTerm.exe on your PC. 
3. Press the "Upgrade" button on the right side of the XTerm window. 
4. Select the file "Xpert2 v?.?.?.?.upg" in the Open dialog. The upgrade will 
   proceed and finish automatically. 

Custom SLLs
-----------
Before upgrading the Xpert, you must be sure to delete from the Flash Disk any 
custom SLLs you have created. After the upgrade is complete, you can rebuild 
your SLL for the new version of Xpert, and then copy it over. [For reference, 
most users do not create their own custom slls. A custom sll is a program 
written for the Xpert using the programming tools we provide for download from 
our website.]

Changing What is Upgraded
-------------------------
You can change what is upgraded by making simple changes to the Xpert2.upg file 
in this upgrade package. You might want to do this when you are upgrading a 
system that you know already has the correct versions of kernel and loader, but 
simply needs a reinstall or updated application. Be careful upgrading components 
in this manner because the components often depend on specific versions of each 
other, and will cease to work when versions don't match. 

Generally speaking, you can skip any step in the upgrade process by adding a 
semi-colon ";" to the beginning of the line that performs the step. To re-enable 
the step, just remove the semi-colon, and reperform the upgrade. 

