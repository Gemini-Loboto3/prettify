define list_cnt			$702000		// 1 byte
define list_srcl		$702001		// 2+1 bytes
define list_srch		$702003
define list_dst			$702005		// 2 bytes
define list_size		$702007		// 2 bytes

define dma_dst			$11d		// 2 bytes
define dma_srcl			$11f		// 2+1 bytes
define dma_srch			$121
define dma_size			$122		// 2 bytes

define list_inv_last	$702100		// stores previous index selection in inventory

define backup_vram		$704000		// buffer to store vram backup (16KB, takes all remaining sram)

define ex_name_ok		$703d70		// when a slot contains 'OK' we don't need to expand names
define ex_name_data		$703d80		// 112 bytes, 14 names *8 bytes
define ex_name_save		$703e00		// where expanded names are saved, 112 bytes per slot

define tm_base_item		$100		// list
define tm_base_magic	$100		// list
define tm_base_magicx	$190		// single spell for selection on menu
define tm_base_equip	$278		// equip screen
define tm_base_job		$2A0		// all screens
define tm_base_name		$2BE		// all screens
