using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace Steganography
{
    public partial class Steganography : Form
    {
        Image img;
        public Steganography()
        {
            InitializeComponent();
        }

        private void Image_Search_Click(object sender, EventArgs e)
        {
            openFileDialog1.ShowDialog();
            img = Image.FromFile(openFileDialog1.FileName);
            pictureBox1.Image = img;
            pictureBox2.Image = img;
        }

        private void revealButton_Click(object sender, EventArgs e)
        {
            string text = "";
            int val = 7;
            int letter = 0;
            Bitmap tmp = new Bitmap(img);
            for (int j = 0; j < tmp.Height; j++)
                for (int i = 0; i < tmp.Width; i++)
                {

                    Color col = tmp.GetPixel(i, j);

                    letter += (col.R % 2) * (int)Math.Pow(2, val--);

                    if (val == -1)
                    {
                        text += (char)letter;
                        if (letter == 0)
                        {
                            textBox1.Text = text;
                            return;
                        }
                        val = 7;
                        letter = 0;
                    }

                    letter += (col.G % 2) * (int)Math.Pow(2, val--);


                    if (val == -1)
                    {
                        text += (char)letter;
                        if (letter == 0)
                        {
                            textBox1.Text = text;
                            return;
                        }
                        val = 7;
                        letter = 0;
                    }
                    letter += (col.B % 2) * (int)Math.Pow(2, val--);

                    if (val == -1)
                    {
                        text += (char)letter;
                        if (letter == 0)
                        {
                            textBox1.Text = text;
                            return;
                        }
                        val = 7;
                        letter = 0;
                    }
                }
            textBox1.Text = text;
        }

        private void HideButton_Click(object sender, EventArgs e)
        {
            string s = textBox2.Text;
            int[] table = new int[s.Length * 8 + 8];
            for (int i = 0; i < s.Length; i++)
            {
                int tmp = s[i];
                for (int j = 7; j > -1; j--)
                {
                    int val = tmp % 2;
                    table[i * 8 + j] = val;
                    tmp /= 2;
                }
            }


            Bitmap res = new Bitmap(img);
            int pos = 0;
            for (int j = 0; j < res.Height; j++)
            {
                for (int i = 0; i < res.Width; i++)
                {
                    Color pixel = res.GetPixel(i, j);
                    int R, G, B;
                    R = pixel.R;
                    G = pixel.G;
                    B = pixel.B;
                    if (pos < table.Length)
                    {
                        if (pixel.R % 2 != table[pos])
                            R += 1;
                        if (R > 255)
                            R -= 2;
                        pos++;
                    }
                    else
                        break;

                    if (pos < table.Length)
                    {
                        if (pixel.G % 2 != table[pos])
                            G += 1;
                        if (G > 255)
                            G -= 2;
                        pos++;
                    }

                    if (pos < table.Length)
                    {
                        if (pixel.B % 2 != table[pos])
                            B += 1;
                        if (B > 255)
                            B -= 2;
                        pos++;
                    }
                    res.SetPixel(i, j, Color.FromArgb(R, G, B));
                }
                if (pos >= table.Length)
                    break;
            }
            res.Save("result.bmp");
        }
    }
}

