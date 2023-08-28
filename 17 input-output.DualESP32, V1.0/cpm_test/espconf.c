#define CONIO_VT100
#include <stdio.h>
#include <conio.h>
#include <stdlib.h>
#include <ctype.h>
#include <cpm.h>

#include "esplowlevel.h"
#include "espui.h"
#include "espconsole.h"
#include "espserial.h"
#include "espsound.h"
#include "espgraphics.h"
#include "espwifi.h"

int cpm_ver;


menu_page1()
{
    char ch;

    printf("\e[2J\e[0m\e[H");
    printcentered("Nhyodyne ESP32 IO board test");
    puts(" ");

    printmenu('H',"Set Display Resolution",NULL,NULL);
    printmenu('I',"Set Terminal Font",NULL,NULL);

    printmenu('7',"Set serial 0 baud rate",NULL,NULL);
    printmenu('8',"Set serial 0 mode",NULL,NULL);
    printmenu('D',"Set Serial 1 baud rate",NULL,NULL);
    printmenu('E',"Set Serial 1 mode",NULL,NULL);

    printmenu('F',"Set Audio Master Volume",NULL,NULL);

    printmenu('Z',"\e[1mExit Program\e[0m",NULL,NULL);

    puts(" ");
    printmenu('1',"Set Hostname",NULL,NULL);
    printmenu('2',"Set Incoming Port",NULL,NULL);
    puts(" ");

    printmenu('J',"Set Wifi SSID");
    printmenu('K',"Set WiFi Password");
    printmenu('L',"Connect To WiFi");
    printmenu('M',"Get WiFi Status");
    printmenu('N',"Get WiFi Signal Strength");
    printmenu('O',"Get IP Address");
    printmenu('P',"Get Subnet Mask");
    printmenu('Q',"Get Gateway");
    printmenu('R',"Get Primary DNS");
    printmenu('S',"Get Secondary DNS");
    printmenu('T',"Set IP Address");
    printmenu('U',"Set Subnet Mask");
    printmenu('V',"Set Gateway");
    printmenu('W',"Set Primary DNS");
    printmenu('X',"Set Secondary DNS");



    for(;;)
    {
        printf("\e[22;1HSelection->\e[1m");
        ch = getchar();
        printf("\e[0m");
        ch = toupper(ch);

        switch (ch)
        {
            case '1':
                send_char_test();
                return 1;
            case '2':
                send_100_char_test();
                printmessage("100 characters sent.");
                break;
            case '3':
                send_string_test();
                printmessage("string sent.");
                break;
            case '4':
                get_key_test();
                return 1;
            case '5':
                get_key_buffer_len_test();
                break;
            case '6':
                cursor_visibility_test();
                return 1;
            case '7':
                serial_baud_rate_test();
                return 1;
            case '8':
                serial_mode_test();
                return 1;
            case '9':
                serial_tx_single_char_test();
                return 1;
            case 'A':
                serial_tx_string_test();
                break;
            case 'B':
                serial_rx_test();
                return 1;
            case 'C':
                serial_length_test();
                break;
            case 'D':
                play_string_test();
                break;
            case 'E':
                play_sound_test();
                return 1;
            case 'F':
                set_volume_test();
                return 1;
            case 'G':
                clear_screen_test();
                break;
            case 'H':
                set_resolution_test();
                return 1;
            case 'I':
                set_font_test();
                return 1;
            case 'J':
                copy_rectangle_test();
                return 1;
            case 'K':
                draw_bitmap_test();
                return 1;
            case 'L':
                draw_char_test();
                return 1;
            case 'M':
                draw_ellipse_test();
                return 1;
            case 'N':
                draw_glyph_test();
                return 1;
            case 'O':
                draw_line_test();
                return 1;
            case 'P':
                draw_rectangle_test();
                return 1;
            case 'Q':
                fill_ellipse_test();
                return 1;
            case 'R':
                fill_rectangle_test();
                return 1;
            case 'S':
                get_pixel_test();
                return 1;
            case 'T':
                invert_rectangle_test();
                return 1;
            case 'U':
                draw_line_to_test();
                return 1;
            case 'V':
                move_cursor_to_test();
                return 1;
            case 'W':
                scroll_test();
                return 1;
            case 'X':
                set_brush_color_test();
                return 1;
            case 'Y':
                return 2;
            case 'Z':
                printf("\e[2J\e[0m\e[H\e[0m\n\r\n\r");
                exit(0);
        }
    }
}

menu_page2()
{
    char ch;

    printf("\e[2J\e[0m\e[H");
    printcentered("Nhyodyne ESP32 IO board test");
    puts(" ");


    for(;;)
    {
        printf("\e[22;1HSelection->\e[1m");
        ch = getchar();
        printf("\e[0m");
        ch = toupper(ch);

        switch (ch)
        {
            case '1':
                set_line_end_test();
                return 2;
            case '2':
                set_pen_color_test();
                return 2;
            case '3':
                set_pen_width_test();
                return 2;
            case '4':
                set_pixel_test();
                return 2;
            case '5':
                set_glyph_options_test();
                return 2;
            case '6':
                set_palette_item_test();
                return 2;
            case '7':
                set_mouse_cursor_test();
                return 2;
            case '8':
                set_mouse_cursor_position_test();
                return 2;
            case '9':
                remove_sprites_test();
                printmessage("Sprites Removed.");
                break;
            case 'A':
                set_sprite_map_test();
                printmessage("Sprite Map Defined.");
                break;
            case 'B':
                set_sprite_location_test();
                return 2;
            case 'C':
                set_sprite_visibility_test();
                return 2;
            case 'D':
                serial2_baud_rate_test();
                return 2;
            case 'E':
                serial2_mode_test();
                return 2;
            case 'F':
                serial2_tx_single_char_test();
                return 2;
            case 'G':
                serial2_tx_string_test();
                break;
            case 'H':
                serial2_rx_test();
                return 2;
            case 'I':
                serial2_length_test();
                break;
            case 'J':
                set_wifi_ssid_test();
                return 2;
            case 'K':
                set_wifi_password_test();
                return 2;
            case 'L':
                connect_to_wifi_test();
                printmessage("Connecting to WiFi.");
                break;
            case 'M':
                get_wifi_status_test();
                break;
            case 'N':
                get_wifi_signal_strength_test();
                break;
            case 'O':
                get_ip_address_test();
                break;
            case 'P':
                get_subnet_mask_test();
                break;
            case 'Q':
                get_gateway_test();
                break;
            case 'R':
                get_primary_dns_test();
                break;
            case 'S':
                get_secondary_dns_test();
                break;
            case 'T':
                set_ip_address_test();
                return 2;
            case 'U':
                set_subnet_mask_test();
                return 2;
            case 'V':
                set_gateway_test();
                return 2;
            case 'W':
                set_primary_dns_test();
                return 2;
            case 'X':
                set_secondary_dns_test();
                return 2;
            case 'Y':
                return 3;
            case 'Z':
                return 1;
        }
    }
}


main()
{
    int menu=1;
    cpm_ver = bdos(CPM_VERS, 0);

    if ((cpm_ver == 0) || (cpm_ver > 0x2F))
        printf("\nWARNING: unsupported CP/M version detected: %x.%x\n\n", cpm_ver >> 4, cpm_ver & 0xf);

    for(;;)
    {
        switch(menu)
        {
            case 1:
                menu=menu_page1();
                break;
            case 2:
                menu=menu_page2();
                break;
            case 3:
                menu=menu_page3();
                break;
            default:
                menu=menu_page1();
                break;
        }
    }

    return 0;
}
