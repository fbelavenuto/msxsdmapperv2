�y	MAPDRV - map a drive to a driver, device, LUN and partition,
         or mount a file on a drive
Usage:

MAPDRV [/L] <drive>: <partition>|d|u [<device>[-<LUN>] [<slot>[-<subslot>]|0]]
MAPDRV <drive>: [/]<filename> [/ro]

Maps the drive to the specified partition of the specified device and LUN
of the driver in the specified slot (must be a device-based driver).

/L locks the drive immediately after doing the mapping.

<partition> can be any number starting at 1, or 0 to map the drive directly
to the device (needed for partitionless devices such as floppy disks).
Partition numbers 2 to 4 refer to extended partitions 2-1 to 2-4 if partition
2 of the device is extended, otherwise they refer to primary partitions.

<device> and <LUN> must be a number from 1 to 7 each one. If <device> is
specifided but <LUN> is omitted, value 1 is assumed for <LUN>.

<slot> and <subslot> must be a number from 0 to 3. If 0 is specified instead,
the primary disk controller slot is assumed.

If device information is provided but slot is omitted, the drive is mapped to
the specified partition of the specified device in the driver already
controlling the drive (this works only if the drive is currently mapped
to a device-based driver).

If both device and slot information are omitted, the drive is mapped to the
specified partition of the device it is already mapped to (this works only if
the drive is currently mapped to a device-based driver).

'd' will revert the drive to its default mapping (the mapping at boot time).
'u' will leave the drive unmapped. Other parameters are ignored in both cases.

If a valid filename is supplied after <drive>, the specified file will be
mapped to the drive. A file cannot be mapped to its own drive, or to a drive
that contains a file that has been mapped. Prepend the filename with '/'
if the first character of his name is a digit.
MAPDRV - map a drive to a driver, device, LUN and partition
         or mount a file on a drive

MAPDRV [/L] <drive>: <partition>|d|u [<device>[-<LUN>] [<slot>[-<subslot>]|0]]
MAPDRV <drive>: [/]<filename> [/ro]

TYPE MAPDRV.COM for more details.
 �#d>ͦ zr� Gb� �! :d�/  #:e� �l >�2[d>ͦ�b� �#!d��=2\d�}�#ͦ�b� �/ʌ!d��0:e�:d� �d�g
�u �g
É2Zd�}�#ͦ�u
:d�1���8���02a:e�(�-��:f�1���8���02bd�}�#ͦ�u
!d�h� :H�2_x2`:\|� Gb� :_< Z:\!dy� Gb� :d��b� :a� :h2a:i2b�#V#^!dx� Gb� :h��b� :d2_:e2`:Z��+�(3�0;!    �!\�~�F�V�^&. z� `Gb� |�(�(:Z2]�2^>2]:Z=2^!    :]�(!�!\�~�F�V�^�f�nz� Gb� �Sc"e:\!_|� G� :[�(:\_>�w� Gb� d@�! 0� ����@0>ͦ ��:@0�/��:A0� �r��:B0� �o��:C0���:\|! 0� Gb� ����b� �b� Z!4ͫo�!  � x�8���x� y�8���x��)	�  � *** File mounting requires Nextor 2.1 or later
$     ��  �
8
�d8��8,�0�w �#�0�
�
0��q �#��6 1�d�#�
0��6 0�#��6 2���7�G:� �7�x��:� O !� 	6 �������!  �g!� ~�(� #(��#~�(� #(���|=ݽ02!� ~� #(��|�(	~� # �� +~� (�(#��}�7�����Z!4ͫo�!  � �\x�8���x� y�8��x��	�  � *** This program requires Nextor 2.0 or later
$*** Bad version of NEXTOR.SYS, version 2.0 or later is required
$~� �o��#~� �f #~� �f��#~�����n��#~���=�~� �a���i���#~�:��#~�����`�~� �a8�i0�#~�: 	#~� ��`��>������0_� ��(��0_�-� �� �x������!|̀�6  ��{r� :000 �
8
�d8��8,�0�w �#�0�
�
0��q �#��6 1�d�#�
0��6 0�#��6 2����	+~�  x� ��#6 �r� ��ط7�x�7�z�7�yJ 	������!0�� ��� �    ~_�08'�:0#z�(�J���  {�0O	�+���#��� �� {�0�E�:�E�~ ����?��� ���������%���+�+�+�����>�2�2������2�{�(*�:(�-��#�����2�{�(�:��#��2�{���:���(�G:����2�:�G:��   ����b� 