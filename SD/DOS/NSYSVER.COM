�%NSYSVER - Change the NEXTOR.SYS version number

Some command line programs will refuse to work if the NEXTOR.SYS version
is too small. This program allows to change the NEXTOR.SYS version
reported by the system (the value returned in DE by the DOSVER function call).
The value displayed by the VER command will not change.

Usage: NSYSVER <major version number>.<minor version number>
NSYSVER - Change the NEXTOR.SYS version number

Usage: NSYSVER <major version number>.<minor version number>

TYPE NSYSVER.COM for more details.
 ��4>�v B�r� r� ͹�~��.���~ ����~ �����
���b� :4����W:5�.��:6������_:7�����_͹�s �r�r� �b� ��* 2 �	��0_� �� �0��:?��0��r� �b� NEXTOR.SYS version changed successfully.
 
Current NEXTOR.SYS version:  �
8
�d8��8,�0�w �#�0�
�
0��q �#��6 1�d�#�
0��6 0�#��6 2���7�G:� �7�x��:� O !� 	6 �������!  �g!� ~�(� #(��#~�(� #(���|=ݽ02!� ~� #(��|�(	~� # �� +~� (�(#��}�7�����Z!4ͫo�!  � �,x�8���x� y�8�\x��	�  � *** This program requires Nextor 2.0 or later
$*** Bad version of NEXTOR.SYS, version 2.0 or later is required
$~� �o#~� �f #~� �f#~���n#~�=�~� �aڝ�iҝ�#~�:#~���`�~� �a8�i0�#~�: 	#~� ��`��>������0_� ��(��0_�-� �� �x������!L�P�6  ��Kr� :000 �
8
�d8��8,�0�w �#�0�
�
0��q �#��6 1�d�#�
0��6 0�#��6 2����	+~�  x� ��#6 �r� Ϳط7�x�7�z�7�yJ 	������! �� ��� �    ~_�08'�:0#z�(����  {�0O	�����#��� �� {�0��:��~ ����?��� ���������%�������������>�2�2�͙�ҝ2�{�(*�:(�-#͙�ҝ2�{�(�:#͙2�{�:���(�G:����2�:�G:��   ͩ��b� 