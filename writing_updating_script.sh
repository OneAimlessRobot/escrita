#!/bin/bash

((rm -rf /mnt/FASTstorage/FASTprogs/webcrookedstuff/pages/botchatsFAST)&&(cp -rv /mnt/FASTstorage/botchatsFAST /mnt/FASTstorage/FASTprogs/webcrookedstuff/pages/))&
((rm -rf /mnt/FASTstorage/FASTprogs/webcrookedstuff/pages/BotchatsFASTNEWEST)&&(cp -rv /mnt/FASTstorage/BotchatsFASTNEWEST /mnt/FASTstorage/FASTprogs/webcrookedstuff/pages/))&
((rm -rf /mnt/FASTstorage/FASTprogs/webcrookedstuff/pages/BotchatsFASTNEWEST2)&&(cp -rv /mnt/FASTstorage/BotchatsFASTNEWEST2 /mnt/FASTstorage/FASTprogs/webcrookedstuff/pages/))&

((rm -rf /mnt/REBORN/webcrookedstuff/pages/botchatsFAST)&&(cp -rv /mnt/FASTstorage/botchatsFAST /mnt/REBORN/webcrookedstuff/pages/))&
((rm -rf /mnt/REBORN/webcrookedstuff/pages/BotchatsFASTNEWEST)&&(cp -rv /mnt/FASTstorage/BotchatsFASTNEWEST /mnt/REBORN/webcrookedstuff/pages/))&
((rm -rf /mnt/REBORN/webcrookedstuff/pages/BotchatsFASTNEWEST2)&&(cp -rv /mnt/FASTstorage/BotchatsFASTNEWEST2 /mnt/REBORN/webcrookedstuff/pages/))&

((rm -rf /mnt/REBORN/botchatsFAST)&&(cp -rv /mnt/FASTstorage/botchatsFAST /mnt/REBORN/))&
((rm -rf /mnt/REBORN/BotchatsFASTNEWEST)&&(cp -rv /mnt/FASTstorage/BotchatsFASTNEWEST /mnt/REBORN/))&
((rm -rf /mnt/REBORN/BotchatsFASTNEWEST2)&&(cp -rv /mnt/FASTstorage/BotchatsFASTNEWEST2 /mnt/REBORN/))&

((rm -rf /mnt/SUPER_CAVALEIRO/botchatsFAST)&&(cp -rv /mnt/FASTstorage/botchatsFAST /mnt/SUPER_CAVALEIRO/))&
((rm -rf /mnt/SUPER_CAVALEIRO/BotchatsFASTNEWEST)&&(cp -rv /mnt/FASTstorage/BotchatsFASTNEWEST /mnt/SUPER_CAVALEIRO/))&
((rm -rf /mnt/SUPER_CAVALEIRO/BotchatsFASTNEWEST2)&&(cp -rv /mnt/FASTstorage/BotchatsFASTNEWEST2 /mnt/SUPER_CAVALEIRO/))&

wait
echo "Done replacing botchats!!!"


echo "Replacing Writing!!!!!"
((rm -rf /mnt/REBORN/Writing2)&&(cp -rv ~/Desktop/Writing2 /mnt/REBORN/))&
((rm -rf /mnt/SUPER_CAVALEIRO/Writing2)&&(cp -rv ~/Desktop/Writing2 /mnt/SUPER_CAVALEIRO/))&
((rm -rf /mnt/FASTstorage/Writing2)&&(cp -rv ~/Desktop/Writing2 /mnt/FASTstorage/))&
((rm -rf /mnt/FASTstorage/GithubFAST/escrita/Writing2)&&(cp -rv ~/Desktop/Writing2 /mnt/FASTstorage/GithubFAST/escrita/))&
((rm -rf /mnt/FASTstorage/FASTprogs/webcrookedstuff/texts/Writing2)&&(cp -rv ~/Desktop/Writing2 /mnt/FASTstorage/FASTprogs/webcrookedstuff/texts/))&
((rm -rf /mnt/REBORN/webcrookedstuff/texts/Writing2)&&(cp -rv ~/Desktop/Writing2 /mnt/REBORN/webcrookedstuff/texts/))&
wait

rm -rf /mnt/FASTstorage/GithubFAST/escrita/writing_updating_script.sh && cp -rv ~/Desktop/writing_updating_script.sh /mnt/FASTstorage/GithubFAST/escrita
rm -rf /mnt/FASTstorage/GithubFAST/escrita/botchat_updating_script.sh && cp -rv ~/Desktop/botchat_updating_script.sh /mnt/FASTstorage/GithubFAST/escrita
pushd /mnt/FASTstorage/GithubFAST/escrita && bash up* && popd
echo "Done replacing Writing!!!!"




