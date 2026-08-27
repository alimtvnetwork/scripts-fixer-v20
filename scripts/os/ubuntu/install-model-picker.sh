#!/bin/bash
# Interactive Model Download Section for Unix

echo -e "\e[1;36mℹ Interactive AI Model Downloader (Ollama/llama.cpp)\e[0m"
echo -e ""
echo "Select a model family to download:"
echo "  1) Qwen 2.5 Coder (7B/14B/32B)"
echo "  2) DeepSeek R1 (8B/14B)"
echo "  3) GLM-4 (9B)"
echo "  4) Llama 3.2 (3B)"
echo "  q) Quit"
echo -e ""
read -p "Selection [1-4, q]: " selection

case $selection in
    1)
        echo "Pulling Qwen 2.5 Coder 7B..."
        ollama pull qwen2.5-coder:7b
        ;;
    2)
        echo "Pulling DeepSeek R1 8B..."
        ollama pull deepseek-r1:8b
        ;;
    3)
        echo "Pulling GLM-4 9B..."
        ollama pull glm4:9b
        ;;
    4)
        echo "Pulling Llama 3.2 3B..."
        ollama pull llama3.2:3b
        ;;
    q|Q)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo -e "\e[1;31m✖ Invalid selection.\e[0m"
        exit 1
        ;;
esac

echo -e "\e[1;32m✔ Download complete.\e[0m"
