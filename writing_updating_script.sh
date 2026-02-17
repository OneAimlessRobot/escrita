#!/bin/bash

((rm -rf /mnt/FASTstorage/FASTprogs/webcrookedstuff/pages/botchatsFAST)&&(cp -rv /mnt/FASTstorage/botchatsFAST /mnt/FASTstorage/FASTprogs/webcrookedstuff/pages/))&
((rm -rf /mnt/FASTstorage/FASTprogs/webcrookedstuff/pages/BotchatsFASTNEWEST)&&(cp -rv /mnt/FASTstorage/BotchatsFASTNEWEST /mnt/FASTstorage/FASTprogs/webcrookedstuff/pages/))&
((rm -rf /mnt/FASTstorage/FASTprogs/webcrookedstuff/pages/BotchatsFASTNEWEST2)&&(cp -rv /mnt/FASTstorage/BotchatsFASTNEWEST2 /mnt/FASTstorage/FASTprogs/webcrookedstuff/pages/))&

wait
echo "Done replacing botchats!!!"


echo "Replacing Writing!!!!!"
((rm -rf /mnt/REBORN/Writing2)&&(cp -rv ~/Desktop/Writing2 /mnt/REBORN/))&
((rm -rf /mnt/SUPER_CAVALEIRO/Writing2)&&(cp -rv ~/Desktop/Writing2 /mnt/SUPER_CAVALEIRO/))&
((rm -rf /mnt/FASTstorage/Writing2)&&(cp -rv ~/Desktop/Writing2 /mnt/FASTstorage/))&
((rm -rf /mnt/FASTstorage/GithubFAST/escrita/Writing2)&&(cp -rv ~/Desktop/Writing2 /mnt/FASTstorage/GithubFAST/escrita/))&
((rm -rf /mnt/FASTstorage/FASTprogs/webcrookedstuff/texts/Writing2)&&(cp -rv ~/Desktop/Writing2 /mnt/FASTstorage/FASTprogs/webcrookedstuff/texts/))&
wait

pushd /mnt/FASTstorage/GithubFAST/escrita && bash up* && popd
echo "Done replacing Writing!!!!"




