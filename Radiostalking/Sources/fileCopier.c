
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

/*thx faculdade*/


void aborta( char *msg )
/* aborta o programa ap�s afixar uma mensagem no STDERR */
{
  if (msg != NULL) fprintf(stderr, "%s\n", msg);
  exit(1);
}



int copy( int argc, int buffsize,char* srcFile,char*dstFile )
{
  int nr, nw;
  void* buf;
  FILE *fin, *fout;

  if ( buffsize <= 0 ) aborta("Tamanho do buffer mal");

  if ( (buf = malloc( buffsize )) == NULL ) aborta("Falta de memoria");

  fin = fopen( srcFile, "r" );
  if ( fin == NULL ) aborta( "Erro no primeiro ficheiro" );

  fout = fopen( dstFile, "w" );
  if ( fout == NULL ) aborta( "Erro no segundo ficheiro" );

  while( (nr = fread( buf, 1, buffsize, fin )) > 0 )    /* A COPIA...*/
  {
    nw = fwrite( buf, 1, nr, fout );
    if ( nw < nr ) aborta( "Erro na escrita" );
  }
  if ( nr < 0 ) aborta( "Erro na leitura" );

  return 0;  /* terminou bem */
}

