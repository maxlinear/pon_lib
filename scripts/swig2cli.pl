#!/usr/bin/perl
use strict;
use warnings;

use lib "../../../lib/lib_cli/scripts";
use xml::xml2c;
use xml::xml2c_co_gpon;

sub main
{
   # generate XML
   my $xml_file = 'swig.xml';

   my @defines = ( 'INCLUDE_CLI_SUPPORT'
                 , '__BIG_ENDIAN'
                 );

   my @files = ( '../include/fapi_pon.h'
               );

   my @misc_cli_files = ();

   my $incpath = '../include -I../src';
   my $ifxos_incpath = '../../lib_ifxos/src/include';

   printf "Generate $xml_file\n";
   generate_xml(\@files, \@defines, $incpath, $ifxos_incpath, $xml_file);

   # generate CLI
   my @includes = ( 'fapi_pon.h'
                  , 'fapi_pon_error.h'
                  , 'pon_cli.h'
                  );

   # includes for case static CLI tree:
   my @includes_st = (
                  );

   my $out_file = '../cli/fapi_pon_cli.c';

   my $xml_config = 'cli_config.xml';

   printf "Generate $out_file\n";

   parse_gpon($xml_file, $xml_config, $out_file, \@includes, 'pon', \@misc_cli_files, 0, \@includes_st);

   system("sed -i \"s/\\r\\n/\\n/g\" $out_file");

   system('sed -i "s/\"errorcode=%d addr=%u data=%u /\"errorcode=%d addr=0x%x data=0x%x /g" ' . $out_file);
   system("sed -i \"s/cli_autogen_commands_register/pon_cli_cmd_register/g\" $out_file");
   # yes we need 10 /, in bash we need \\\\ for the one / and /" for the ",
   # because of perl we have to escape all / again, this makes 10. ;-)
   system('sed -i "s/pon_id=\\\\\\\\\\"%u %u %u %u %u %u %u\\\\\\\\\\"/pon_id=\\\\\\\\\\"%x %x %x %x %x %x %x\\\\\\\\\\"/g" ' . $out_file);

}

main();
