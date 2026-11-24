/*
  UniWriter – APDE / Processing Android
  Benutzeroberfläche für 1080 × 2400 px
  mit verzerrungsfreier Zeichen- und Exportdarstellung.

  WICHTIG:
  Lege sämtliche verwendeten Zeichenbilder in den Ordner "data".
  Die Dateinamen stehen in imageMapping weiter unten.
*/

import java.util.*;
import java.io.*;
import android.media.MediaScannerConnection;
import android.content.Context;

class Token {
  String value;
  String align;

  Token(String v, String a) {
    value = v;
    align = a;
  }
}

class LineData {
  String align;
  ArrayList<Token> tokens = new ArrayList<Token>();
  LineData(String a) { align = a; }
}

class TokenMetrics {
  float iw;
  float ih;
  float yOff;
  float adv;
  boolean isImage;

  TokenMetrics(float iw, float ih, float yOff, float adv, boolean isImage) {
    this.iw = iw;
    this.ih = ih;
    this.yOff = yOff;
    this.adv = adv;
    this.isImage = isImage;
  }
}

HashMap<String, PImage> images = new HashMap<String, PImage>();
HashMap<String, String> imageMapping = new HashMap<String, String>();
HashMap<String, float[]> charConfig = new HashMap<String, float[]>();
ArrayList<Token> tokenList = new ArrayList<Token>();

int rtlStartIndex = -1;
boolean underscoreMode = false;
boolean isFirstKey = true;
String activeAlignment = "left";
String statusText = "Standard-Modus (Links nach Rechts)";
String notice = "";

int editorWidth = 360;
int editorHeight = 110;
int charSize = 36;

PFont headerFont;
PFont monoFont;

String[][] keyboardLayout = {
  {"1","2","3","4","5"},
  {"6","7","8","9","0"},
  {"q","w","e","r","t","z","u","i","o","p"},
  {"a","s","d","f","g","h","j","k","l","."},
  {"y","x","c","v","b","n","m","_"},
  {"SPACE","#","/","BACK","ENTER"}
};

int topArea;
int keyboardTop;
int keyH;
int margin = 20;

void settings() {
  fullScreen();
}

void setup() {
  orientation(PORTRAIT);
  textFont(createFont("Monospaced", 24));
  textAlign(LEFT, TOP);
  defineCharacters();
  defineImages();
  loadImages();
  updateLayoutMetrics();
  setDefaultEditorSizes();
  notice = "Bilder und ReadMe in Android/media/processing.test.uniwriter_20261120b";
  
  
  
  monoFont = createFont("Monospaced", 24);
  headerFont = createFont("SansSerif", 44);
  textFont(monoFont);


  
}

void draw() {
  updateLayoutMetrics();
  background(238, 241, 245);
  drawHeader();
  drawSettings();
  drawModeAndAlignment();
  drawControlText();
  drawExportButtons();
  drawEditor();
  drawKeyboard();
  drawNotice();
}

// --- Zentrale Layout- & Skalierungsberechnung ---

float getUiScale() {
  return constrain(min(width / 1080.0, height / 2400.0), 0.45, 1.5);
}

int sPx(float px) {
  return max(1, round(px * getUiScale()));
}

int sFont(float px, float minPx, float maxPx) {
  return constrain(round(px * getUiScale()), round(minPx), round(maxPx));
}

int getGap() {
  return sPx(14);
}

int getNoticeHeight() {
  return notice.length() > 0 ? sPx(72) : sPx(12);
}

int getHeaderHeight() {
  return sPx(68);
}



int getSettingsBoxHeight() {
  return max(sPx(195), sPx(115) + max(sPx(65), sPx(76)));
}

int getModeAreaHeight() {
  int statusH = max(sPx(80), 75);
  int btnH = max(sPx(82), 75);
  int gap = getGap();
  return statusH + btnH + gap;
}

int getControlBoxHeight() {
  return sPx(145);
}

int getExportButtonHeight() {
  return constrain(sPx(90), 85, 95);
}

int getKeyGap() {
  return sPx(10);
}

void updateLayoutMetrics() {
  margin = sPx(20);
  int gap = getGap();
  int headerY = sPx(14);
  int settingsY = headerY + getHeaderHeight() + gap;
  int modeY = settingsY + getSettingsBoxHeight() + gap;
  int ctrlY = modeY + getModeAreaHeight() + gap;
  int exportY = ctrlY + getControlBoxHeight() + gap;
  topArea = exportY + getExportButtonHeight() + gap;

  keyH = constrain(sPx(92), 60, 100);
  int totalKbH = keyboardTotalHeight();
  keyboardTop = height - totalKbH - getNoticeHeight() - sPx(8);
}

void setDefaultEditorSizes() {
  editorWidth = width - 2 * margin;
  charSize = constrain(round(editorWidth / 10.0), 18, 80);
  float lineGap = charSize * 0.15 + sPx(6);
  editorHeight = round(3 * (charSize + lineGap) + sPx(20));
  editorWidth  = constrain(editorWidth, 200, 1200);
  editorHeight = constrain(editorHeight, 80, 600);
  charSize     = constrain(charSize, 14, 300);
}

void defineCharacters() {
  // Werte: Breite, H����������he, vertikaler Versatz, Abstand
  putCfg("a", 1, 1, 0, 1); 
  putCfg("b", 1, 1, 0, 1);
  putCfg("c", 1, 1, 0, 1); 
  putCfg("d", 1, 1, 0, 1);
  putCfg("e", 1, 1, 0, 1); 
  putCfg("f", 1, 1, 0, 1);
  putCfg("g", 1, 1, 0, 1); 
  putCfg("h", 1, 1, 0, 1);
  putCfg("i", 1, 1, 0, 1); 
  putCfg("j", 1, 1, 0, 1);
  putCfg("k", 1, 1, 0, 1); 
  putCfg("l", 1, 1, 0, 1);
  putCfg("m", 1, 1, 0, 1); 
  putCfg("n", 1, 1, 0, 1);
  putCfg("o", 1, 1, 0, 1); 
  putCfg("p", 1, 1, 0, 1);
  putCfg("q", 1, 1, 0, 1); 
  putCfg("r", 1, 1, 0, 1);
  putCfg("s", 1, 1, 0, 1); 
  putCfg("t", 1, 1, 0, 1); 
  putCfg("u", 1, 1, 0, 1); 
  putCfg("v", 1, 1, 0, 1);
  putCfg("w", 1, 1, 0, 1); 
  putCfg("x", 1, 1, 0, 1);
  putCfg("y", 1, 1, 0, 1); 
  putCfg("z", 1, 1, 0, 1);
  
  putCfg(".", 1, 1, 0, 1);
  putCfg(" ", 1, 1, 0, 1);
  putCfg("space2", 1, 1, 0, 1);
  putCfg("/", 1, 1, 0, 1);
  putCfg("#", 1, 1, 0, 1);

  for (int d = 0; d <= 9; d++) {
    putCfg(str(d), 1, 1, 0, 1);
  }

  putCfg("a2", 1, 1, 0, 1); 
  putCfg("b2", 1, 1, 0, 1);
  putCfg("c2", 1, 1, 0, 1); 
  putCfg("d2", 1, 1, 0, 1);
  putCfg("e2", 1, 1, 0, 1); 
  putCfg("f2", 1, 1, 0, 1);
  putCfg("g2", 1, 1, 0, 1); 
  putCfg("h2", 1, 1, 0, 1);
  putCfg("i2", 1, 1, 0, 1); 
  putCfg("j2", 1, 1, 0, 1);
  putCfg("k2", 1, 1, 0, 1); 
  putCfg("l2", 1, 1, 0, 1);
  putCfg("m2", 1, 1, 0, 1); 
  putCfg("n2", 1, 1, 0, 1);
  putCfg("o2", 1, 1, 0, 1); 
  putCfg("p2", 1, 1, 0, 1);
  putCfg("q2", 1, 1, 0, 1); 
  putCfg("r2", 1, 1, 0, 1);
  putCfg("s2", 1, 1, 0, 1); 
  putCfg("t2", 1, 1, 0, 1); 
  putCfg("u2", 1, 1, 0, 1); 
  putCfg("v2", 1, 1, 0, 1);
  putCfg("w2", 1, 1, 0, 1); 
  putCfg("x2", 1, 1, 0, 1);
  putCfg("y2", 1, 1, 0, 1); 
  putCfg("z2", 1, 1, 0, 1);

  putCfg("_a", 1, 1, 0, 1); 
  putCfg("_b", 1, 1, 0, 1);
  putCfg("_c", 1, 1, 0, 1); 
  putCfg("_d", 1, 1, 0, 1); 
  putCfg("_e", 1, 1, 0, 1); 
  putCfg("_f", 1, 1, 0, 1);
  putCfg("_g", 1, 1, 0, 1);
  putCfg("_h", 1, 1, 0, 1);
  putCfg("_i", 1, 1, 0, 1); 
  putCfg("_j", 1, 1, 0, 1);
  putCfg("_k", 1, 1, 0, 1); 
  putCfg("_l", 1, 1, 0, 1); 
  putCfg("_m", 1, 1, 0, 1);
  putCfg("_n", 1, 1, 0, 1);
  putCfg("_o", 1, 1, 0, 1); 
  putCfg("_p", 1, 1, 0, 1);
  putCfg("_q", 1, 1, 0, 1); 
  putCfg("_r", 1, 1, 0, 1);
  putCfg("_s", 1, 1, 0, 1);
  putCfg("_t", 1, 1, 0, 1);
  putCfg("_u", 1, 1, 0, 1); 
  putCfg("_v", 1, 1, 0, 1);
  putCfg("_w", 1, 1, 0, 1); 
  putCfg("_x", 1, 1, 0, 1); 
  putCfg("_y", 1, 1, 0, 1);
  putCfg("_z", 1, 1, 0, 1);
}


void putCfg(String k, float w, float h, float y, float sp) {
  charConfig.put(k, new float[]{w,h,y,sp});
}

void defineImages() {
  addImage("a","a.png");
  addImage("b","b.png");
  addImage("c","c.png");
  addImage("d","d.png");
  addImage("e","e.png");
  addImage("f","f.png");
  addImage("g","g.png");
  addImage("h","h.png");
  addImage("i","i.png");
  addImage("j","j.png");
  addImage("k","k.png");
  addImage("l","l.png");
  addImage("m","m.png");
  addImage("n","n.png");
  addImage("o","o.png");
  addImage("p","p.png");
  addImage("q","q.png");
  addImage("r","r.png");
  addImage("s","s.png");
  addImage("t","t.png");
  addImage("u","u.png");
  addImage("v","v.png");
  addImage("w","w.png");
  addImage("x","x.png");
  addImage("y","y.png");
  addImage("z","z.png");

  addImage("1","1.png");
  addImage("2","2.png");
  addImage("3","3.png");
  addImage("4","4.png");
  addImage("5","5.png");
  addImage("6","6.png");
  addImage("7","7.png");
  addImage("8","8.png");
  addImage("9","9.png");
  addImage("0","0.png");

  addImage(" ","space.png");
  addImage("space2","space2.png");
  addImage(".","dot.png");
  addImage("#","number.png");
  addImage("/","slash.png");

  addImage("a2","a2.png");
  addImage("b2","b2.png");
  addImage("c2","c2.png");
  addImage("d2","d2.png");
  addImage("e2","e2.png");
  addImage("f2","f2.png");
  addImage("g2","g2.png");
  addImage("h2","h2.png");
  addImage("i2","i2.png");
  addImage("j2","j2.png");
  addImage("k2","k2.png");
  addImage("l2","l2.png");
  addImage("m2","m2.png");
  addImage("n2","n2.png");
  addImage("o2","o2.png");
  addImage("p2","p2.png");
  addImage("q2","q2.png");
  addImage("r2","r2.png");
  addImage("s2","s2.png");
  addImage("t2","t2.png");
  addImage("u2","u2.png");
  addImage("v2","v2.png");
  addImage("w2","w2.png");
  addImage("x2","x2.png");
  addImage("y2","y2.png");
  addImage("z2","z2.png");

  addImage("_a","_a.png");
  addImage("_b","_b.png");
  addImage("_c","_c.png");
  addImage("_d","_d.png");
  addImage("_e","_e.png");
  addImage("_f","_f.png");
  addImage("_g","_g.png");
  addImage("_h","_h.png");
  addImage("_i","_i.png");
  addImage("_j","_j.png");
  addImage("_k","_k.png");
  addImage("_l","_l.png");
  addImage("_m","_m.png");
  addImage("_n","_n.png");
  addImage("_o","_o.png");
  addImage("_p","_p.png");
  addImage("_q","_q.png");
  addImage("_r","_r.png");
  addImage("_s","_s.png");
  addImage("_t","_t.png");
  addImage("_u","_u.png");
  addImage("_v","_v.png");
  addImage("_w","_w.png");
  addImage("_x","_x.png");
  addImage("_y","_y.png");
  addImage("_z","_z.png");
}

void addImage(String key, String file) {
  imageMapping.put(key, file);
}

File getUniwriterImagesDir() {
  try {
    Context ctx = getActivity().getApplicationContext();
    if (ctx != null) {
      File[] mediaDirs = ctx.getExternalMediaDirs();
      if (mediaDirs != null && mediaDirs.length > 0 && mediaDirs[0] != null) {
        File dir = new File(mediaDirs[0], "uniwriter");
        if (!dir.exists()) {
          boolean created = dir.mkdirs();
          if (created) {
            println("uniwriter-Ordner erstellt: " + dir.getAbsolutePath());
          }
        }
        if (dir.exists() && dir.isDirectory()) {
          return dir;
        }
      }
    }
  } catch (Exception e) {
    println("Fehler bei getUniwriterImagesDir: " + e.getMessage());
  }
  return null;
}

boolean isUniwriterDirEmpty(File dir) {
  if (dir == null || !dir.exists()) return true;
  String[] existing = dir.list();
  if (existing == null || existing.length == 0) return true;
  
  for (String fileName : imageMapping.values()) {
    if (fileName != null && new File(dir, fileName).exists()) {
      return false;
    }
  }
  return true;
}

InputStream openSketchDataStream(String fileName) {
  InputStream in = createInput(fileName);
  if (in != null) return in;

  in = createInput("data/" + fileName);
  if (in != null) return in;

  File direct = new File(sketchPath("data"), fileName);
  if (direct.exists() && direct.isFile()) {
    try {
      return new FileInputStream(direct);
    } catch (Exception ignored) {}
  }
  return null;
}

void populateUniwriterFromSketchData(File targetDir) {
  if (targetDir == null) {
    notice = "Zielordner (Android/media/.../uniwriter) nicht erreichbar";
    return;
  }

  writeReadmeFile(targetDir);

  int copied = 0;
  int missing = 0;

  for (String fileName : imageMapping.values()) {
    if (fileName == null) continue;
    File dstFile = new File(targetDir, fileName);
    if (dstFile.exists()) continue;

    InputStream in = null;
    OutputStream out = null;
    try {
      in = openSketchDataStream(fileName);
      if (in == null) {
        missing++;
        continue;
      }
      out = new FileOutputStream(dstFile);
      byte[] buf = new byte[8192];
      int len;
      while ((len = in.read(buf)) > 0) {
        out.write(buf, 0, len);
      }
      copied++;
    } catch (Exception e) {
      missing++;
    } finally {
      if (in != null) try { in.close(); } catch (Exception ignored) {}
      if (out != null) try { out.close(); } catch (Exception ignored) {}
    }
  }

  if (copied > 0) {
    try {
      Context ctx = getActivity().getApplicationContext();
      ArrayList<String> pathsList = new ArrayList<String>();
      for (String fileName : imageMapping.values()) {
        if (fileName == null) continue;
        File f = new File(targetDir, fileName);
        if (f.exists()) pathsList.add(f.getAbsolutePath());
      }
      if (!pathsList.isEmpty()) {
        MediaScannerConnection.scanFile(
          ctx,
          pathsList.toArray(new String[0]),
          new String[]{"image/png"},
          null
        );
      }
    } catch (Exception ignored) {}
    notice = copied + " Bilder nach Android/media/.../uniwriter kopiert";
  } else {
    notice = "0 kopiert (" + missing + " nicht gefunden) | " + sketchPath("data");
  }
}

void loadImages() {
  images.clear();
  File imgDir = getUniwriterImagesDir();

  if (imgDir != null && isUniwriterDirEmpty(imgDir)) {
    populateUniwriterFromSketchData(imgDir);
    writeReadmeFile(imgDir); 
  }

writeReadmeFile(imgDir); 

  for (String key : imageMapping.keySet()) {
    String fileName = imageMapping.get(key);
    try {
      PImage img = null;
      
      if (imgDir != null) {
        File candidate = new File(imgDir, fileName);
        if (candidate.exists() && candidate.isFile()) {
          img = loadImage(candidate.getAbsolutePath());
        }
      }
      
      if (img == null) {
        img = loadImage(fileName);
      }
      
      if (img != null && img.width > 0 && img.height > 0) {
        images.put(key, img);
      }
    } catch (Exception e) {
      // Nicht vorhandene PNG-Grafiken ignorieren
    }
  }

  if (!images.isEmpty()) {
    if (imgDir != null) {
      notice = images.size() + " Zeichenbilder aus Android/media/.../uniwriter geladen";
    } else {
      notice = images.size() + " Zeichenbilder aus data-Ordner geladen";
    }
  } else {
    notice = "Keine Zeichenbilder gefunden!";
  }
}

void writeReadmeFile(File targetDir) {
  if (targetDir == null) return;

  File readmeFile = new File(targetDir, "README.txt");
  // Nur überspringen, wenn die Datei existiert und nicht leer ist
  if (readmeFile.exists() && readmeFile.length() > 0) return;

  InputStream in = null;
  OutputStream out = null;
  try {
    in = openSketchDataStream("README.txt");
    if (in != null) {
      File tmpOut = new File(targetDir, "README.txt.tmp");
      out = new FileOutputStream(tmpOut);
      byte[] buf = new byte[8192];
      int len;
      long totalBytes = 0;
      while ((len = in.read(buf)) > 0) {
        out.write(buf, 0, len);
        totalBytes += len;
      }
      out.close();
      out = null;

      if (totalBytes > 0) {
        if (readmeFile.exists()) readmeFile.delete();
        if (tmpOut.renameTo(readmeFile)) return;
      } else {
        tmpOut.delete();
      }
    }

    // Fallback: README direkt erzeugen, falls nicht vorhanden oder im data-Ordner leer
    String fallbackReadme =
      "UniWriter – Zeichenbilder & Exporte\n" +
      "====================================\n\n" +
      "Dieses Verzeichnis wird von UniWriter fuer Zeichenbilder (PNG)\n" +
      "sowie fuer exportierte Dateien (PNG und HTML) verwendet.\n\n" +
      "- Eigene PNG-Dateien koennen hier abgelegt werden (siehe imageMapping).\n" +
      "- PNG- und HTML-Exporte landen ebenfalls in diesem Ordner.\n" +
      "- Bei HTML-Exporten sollten die Bilddateien im selben Ordner liegen.\n";

    BufferedWriter writer = new BufferedWriter(
      new OutputStreamWriter(new FileOutputStream(readmeFile), "UTF-8")
    );
    try {
      writer.write(fallbackReadme);
    } finally {
      writer.close();
    }
  } catch (Exception e) {
    println("Fehler beim Schreiben der README.txt: " + e.getMessage());
  } finally {
    if (in != null) try { in.close(); } catch (Exception ignored) {}
    if (out != null) try { out.close(); } catch (Exception ignored) {}
  }
}




void drawHeader() {
  int h = getHeaderHeight();
  float centerY = sPx(10) + h / 2.0;
  float x = width / 2.0;
  int sz = sFont(44, 36, 52);

  pushStyle();
  textFont(headerFont);
  textSize(sz);
  textAlign(CENTER, CENTER);
  fill(44, 62, 80);

  // Kräftigerer Strich durch minimalen subpixel-/1px-Versatz ohne erneutes Font-Laden
  text("UniWriter", x, centerY);
  text("UniWriter", x + sPx(1), centerY);
  text("UniWriter", x, centerY + sPx(1));
  popStyle();
}



int[] getSettingsRowRects() {
  int gap = getGap();
  int y = sPx(14) + getHeaderHeight() + gap;
  int boxW = (width - 2 * margin - 2 * gap) / 3;
  int boxH = getSettingsBoxHeight();
  return new int[]{y, boxW, boxH};
}

int[] getValueButtonRects(int boxX, int boxY, int boxW, int boxH) {
  int btnW = max(sPx(100), 70);
  int btnH = max(sPx(76), 65);
  int pad = sPx(10);
  int btnY = boxY + boxH - btnH - pad;
  int minusX = boxX + pad;
  int plusX = boxX + boxW - pad - btnW;
  return new int[]{minusX, btnY, btnW, btnH, plusX, btnY, btnW, btnH};
}

void drawSettings() {
  int[] r = getSettingsRowRects();
  int y = r[0];
  int boxW = r[1];
  int gap = getGap();
  drawValueControl(margin, y, boxW, "Breite", editorWidth, 40);
  drawValueControl(margin + boxW + gap, y, boxW, "Höhe", editorHeight, 20);
  drawValueControl(margin + 2 * (boxW + gap), y, boxW, "Zeichen", charSize, 4);
}

void drawValueControl(int x, int y, int w, String label, int value, int step) {
  int boxH = getSettingsBoxHeight();
  int pad = sPx(10);
  int[] b = getValueButtonRects(x, y, w, boxH);
  int minusX = b[0], btnY = b[1], btnW = b[2], btnH = b[3], plusX = b[4];

  fill(255);
  stroke(195);
  strokeWeight(sPx(2));
  rect(x, y, w, boxH, sPx(12));
  strokeWeight(1);

  fill(100);
  textSize(sFont(32, 30, 36));
  textAlign(CENTER, TOP);
  text(label, x + w / 2.0, y + pad);

  fill(44, 62, 80);
  textSize(sFont(45, 42, 48));
  textAlign(CENTER, CENTER);
  int valueCenterY = y + pad + sPx(36) + (btnY - (y + pad + sPx(36))) / 2;
  text(str(value), x + w / 2.0, valueCenterY);

  fill(230);
  stroke(170);
  rect(minusX, btnY, btnW, btnH, sPx(10));
  fill(44, 62, 80);
  textSize(sFont(42, 38, 44));
  textAlign(CENTER, CENTER);
  text("-", minusX + btnW / 2.0, btnY + btnH / 2.0 - sPx(2));

  fill(230);
  stroke(170);
  rect(plusX, btnY, btnW, btnH, sPx(10));
  fill(44, 62, 80);
  textSize(sFont(42, 38, 44));
  textAlign(CENTER, CENTER);
  text("+", plusX + btnW / 2.0, btnY + btnH / 2.0 - sPx(2));

  textAlign(LEFT, TOP);
}

int[] getModeLayoutMetrics() {
  int gap = getGap();
  int[] sRect = getSettingsRowRects();
  int y = sRect[0] + sRect[2] + gap;
  int statusH = max(sPx(80), 75);
  int row1Y = y + statusH + gap;
  int btnH = max(sPx(82), 75);
  int bw = (width - 2 * margin - 2 * gap) / 3;
  return new int[]{y, statusH, row1Y, btnH, bw, gap};
}

void drawModeAndAlignment() {
  int[] m = getModeLayoutMetrics();
  int y = m[0];
  int statusH = m[1];
  int row1Y = m[2];
  int btnH = m[3];
  int bw = m[4];
  int gap = m[5];

  if (underscoreMode) fill(230, 126, 34);
  else fill(189, 195, 199);
  noStroke();
  rect(margin, y, width - 2 * margin, statusH, sPx(12));

  fill(underscoreMode ? 255 : 44, underscoreMode ? 255 : 62, underscoreMode ? 255 : 80);
  textSize(sFont(30, 30, 36));
  textAlign(CENTER, CENTER);
  text(statusText, width / 2.0, y + statusH / 2.0);

  drawAlignButton(margin, row1Y, bw, btnH, "Links", "left");
  drawAlignButton(margin + bw + gap, row1Y, bw, btnH, "Mitte", "center");
  drawAlignButton(margin + 2 * (bw + gap), row1Y, bw, btnH, "Rechts", "right");

  textAlign(LEFT, TOP);
}

void drawAlignButton(int x, int y, int w, int h, String label, String align) {
  boolean active = activeAlignment.equals(align);
  fill(active ? color(44, 62, 80) : color(255));
  stroke(180);
  strokeWeight(sPx(2));
  rect(x, y, w, h, sPx(10));
  strokeWeight(1);
  fill(active ? 255 : 70);
  textSize(sFont(32, 30, 36));
  textAlign(CENTER, CENTER);
  text(label, x + w / 2.0, y + h / 2.0);
  textAlign(LEFT, TOP);
}

int[] getControlLayoutRects() {
  int gap = getGap();
  int[] m = getModeLayoutMetrics();
  int y = m[2] + m[3] + gap;
  int h = getControlBoxHeight();
  return new int[]{margin, y, width - 2 * margin, h};
}

void drawControlText() {
  int[] r = getControlLayoutRects();
  int x = r[0], y = r[1], w = r[2], h = r[3];
  int pad = sPx(14);

  fill(44, 62, 80);
  noStroke();
  rect(x, y, w, h, sPx(12));

  fill(190, 200, 205);
  textSize(sFont(30, 30, 36));
  textAlign(LEFT, TOP);
  text("TEXT-KONTROLLE", x + pad, y + pad);

  fill(255);
  textSize(sFont(34, 30, 36));
  String s = getControlText();
  int textTop = y + pad + sPx(40);
  text(s, x + pad, textTop, w - 2 * pad, h - (textTop - y) - pad);
}

int[] getExportLayoutMetrics() {
  int gap = getGap();
  int[] c = getControlLayoutRects();
  int y = c[1] + c[3] + gap;
  int h = getExportButtonHeight();
  int bw = (width - 2 * margin - 2 * gap) / 3;
  return new int[]{y, h, bw, gap};
}

void drawExportButtons() {
  int[] e = getExportLayoutMetrics();
  int y = e[0];
  int bh = e[1];
  int bw = e[2];
  int gap = e[3];
  String[] labels = {"PNG Export", "HTML Export", "Löschen"};

  for (int i = 0; i < 3; i++) {
    int bx = margin + i * (bw + gap);
    fill(i == 0 ? color(46, 204, 113) : i == 1 ? color(230, 126, 34) : color(231, 76, 60));
    noStroke();
    rect(bx, y, bw, bh, sPx(12));
    fill(255);
    textSize(sFont(32, 30, 36));
    textAlign(CENTER, CENTER);
    text(labels[i], bx + bw / 2.0, y + bh / 2.0);
  }
  textAlign(LEFT, TOP);
}

int[] getEditorLayoutRects() {
  int gap = getGap();
  int[] e = getExportLayoutMetrics();
  int y = e[0] + e[1] + gap;
  int bottomLimit = keyboardTop - gap;
  int maxH = max(sPx(120), bottomLimit - y);
  int h = max(sPx(120), min(editorHeight, maxH));
  return new int[]{margin, y, width - 2 * margin, h};
}

void drawEditor() {
  int[] r = getEditorLayoutRects();
  int x = r[0], y = r[1], w = r[2], h = r[3];
  int pad = sPx(14);

  fill(255);
  stroke(189, 195, 199);
  strokeWeight(sPx(2));
  rect(x, y, w, h, sPx(10));
  strokeWeight(1);

  drawTokens(x + pad, y + pad, w - 2 * pad, h - 2 * pad, charSize);
}

// --- Einheitliche, verzerrungsfreie Zeichenmetriken ---

TokenMetrics getTokenMetrics(Token t, float size) {
  if (t.value.equals("CURSOR")) {
    float cursorW = max(3, size * 0.08);
    float adv = cursorW + size * 0.06;
    return new TokenMetrics(cursorW, size, 0, adv, false);
  }

  if (!imageMapping.containsKey(t.value)) {
    return new TokenMetrics(0, 0, 0, 0, false);
  }

  PImage img = images.get(t.value);
  if (img == null || img.width <= 0 || img.height <= 0) {
    return new TokenMetrics(0, 0, 0, 0, false);
  }

  float[] cfg = charConfig.containsKey(t.value) ? charConfig.get(t.value) : new float[]{1, 1, 0, 1};
  float hCfg = cfg[1];
  float yCfg = cfg[2];
  float spCfg = cfg[3];

  float imgAspect = (float) img.width / (float) img.height;
  float targetH = size * hCfg;
  float targetW = targetH * imgAspect;
  float yOff = size * yCfg;

  float adv = targetW + size * 0.06 * spCfg;
  return new TokenMetrics(targetW, targetH, yOff, adv, true);
}

void drawTokens(float x, float y, float w, float h, float size) {
  ArrayList<LineData> lines = makeLines();
  float lineY = y;
  float lineGap = size * 0.15 + sPx(6);

  for (LineData line : lines) {
    float total = measureLine(line.tokens, size);
    float startX = x;
    if (line.align.equals("center")) startX += (w - total) / 2.0;
    if (line.align.equals("right")) startX += w - total;

    float cx = startX;
    for (Token t : line.tokens) {
      TokenMetrics tm = getTokenMetrics(t, size);
      if (t.value.equals("CURSOR")) {
        fill(230, 126, 34);
        noStroke();
        rect(cx, lineY, tm.iw, tm.ih);
        cx += tm.adv;
      } else if (tm.isImage) {
        PImage img = images.get(t.value);
        if (img != null) {
          image(img, cx, lineY + tm.yOff, tm.iw, tm.ih);
        }
        cx += tm.adv;
      }
    }
    lineY += size + lineGap;
  }
}

float measureLine(ArrayList<Token> line, float size) {
  float total = 0;
  for (Token t : line) {
    TokenMetrics tm = getTokenMetrics(t, size);
    total += tm.adv;
  }
  return total;
}

ArrayList<LineData> makeLines() {
  ArrayList<LineData> lines = new ArrayList<LineData>();
  lines.add(new LineData(activeAlignment));
  for (int i = 0; i < tokenList.size(); i++) {
    if (underscoreMode && rtlStartIndex == i) {
      lines.get(lines.size() - 1).tokens.add(new Token("CURSOR", activeAlignment));
    }
    Token t = tokenList.get(i);
    if (t.value.equals("ENTER")) lines.add(new LineData(t.align));
    else {
      lines.get(lines.size() - 1).align = t.align;
      lines.get(lines.size() - 1).tokens.add(t);
    }
  }
  if (!(underscoreMode && rtlStartIndex >= 0) && !isFirstKey) {
    lines.get(lines.size() - 1).tokens.add(new Token("CURSOR", activeAlignment));
  }
  return lines;
}

int keyboardTotalHeight() {
  int gap = getKeyGap();
  int rows = keyboardLayout.length;
  return rows * (keyH + gap) + gap;
}

void drawKeyboard() {
  int rows = keyboardLayout.length;
  int gap = getKeyGap();
  int usableW = width - 2 * margin;
  int keyLabelSize = sFont(40, 38, 44);

  for (int r = 0; r < rows; r++) {
    String[] row = keyboardLayout[r];
    int count = 0;
    for (String k : row) if (!k.equals("")) count++;
    if (count == 0) continue;
    int kw = (usableW - (count - 1) * gap) / count;
    int x = margin;
    int ky = keyboardTop + r * (keyH + gap);
    for (String k : row) {
      if (k.equals("")) continue;
      fill(255);
      stroke(150);
      strokeWeight(sPx(2));
      rect(x, ky, kw, keyH, sPx(10));
      strokeWeight(1);

      fill(35);
      textAlign(CENTER, CENTER);
      textSize(keyLabelSize);
      String label = k;
      if (k.equals("SPACE")) label = "Leer";
      if (k.equals("BACK")) label = "⌫";
      if (k.equals("ENTER")) label = "↵";
      text(label, x + kw / 2.0, ky + keyH / 2.0);
      x += kw + gap;
    }
  }
  textAlign(LEFT, TOP);
}

void drawNotice() {
  if (notice.length() > 0) {
    int nh = getNoticeHeight();
    fill(160, 60, 40);
    textSize(sFont(28, 24, 32));
    textAlign(CENTER, CENTER);
    text(notice, margin, height - nh - sPx(4), width - 2 * margin, nh);
    textAlign(LEFT, TOP);
  }
}

String getControlText() {
  ArrayList<ArrayList<String>> lines = new ArrayList<ArrayList<String>>();
  lines.add(new ArrayList<String>());
  for (Token t : tokenList) {
    if (t.value.equals("ENTER")) lines.add(new ArrayList<String>());
    else lines.get(lines.size() - 1).add(t.value);
  }
  String result = "";
  for (int li = 0; li < lines.size(); li++) {
    ArrayList<String> src = lines.get(li);
    ArrayList<String> out = new ArrayList<String>();
    ArrayList<String> rtl = new ArrayList<String>();
    for (String s : src) {
      if (s.startsWith("_") && !s.equals("_")) rtl.add(controlToken(s));
      else {
        if (rtl.size() > 0) {
          Collections.reverse(rtl);
          out.addAll(rtl);
          rtl.clear();
        }
        out.add(controlToken(s));
      }
    }
    if (rtl.size() > 0) { Collections.reverse(rtl); out.addAll(rtl); }
    for (String s : out) result += s;
    if (li < lines.size() - 1) result += "\n";
  }
  return result;
}

String controlToken(String s) {
  if (s.equals(" ")) return " ";
  if (s.equals(".")) return ".";
  if (s.startsWith("_") && !s.equals("_")) return s.substring(1);
  return s;
}

void checkFirstKey() {
  if (isFirstKey) isFirstKey = false;
}

void insertToken(String value) {
  Token t = new Token(value, activeAlignment);
  if (underscoreMode && rtlStartIndex >= 0) tokenList.add(rtlStartIndex, t);
  else tokenList.add(t);
}

void handleNewChar(String input) {
  String c = input.toLowerCase();
  checkFirstKey();

  if (c.equals("_")) {
    underscoreMode = !underscoreMode;
    rtlStartIndex = underscoreMode ? tokenList.size() : -1;
    statusText = underscoreMode ? "Unterstrich-Modus (Rechts nach Links)" : "Standard-Modus (Links nach Rechts)";
    return;
  }

  // Kombination mit vorherigem Token (z. B. "a" + "2" -> "a2", " " + "2" -> "space2")
  if (c.equals("2") && tokenList.size() > 0) {
    int targetIdx = (underscoreMode && rtlStartIndex >= 0) ? rtlStartIndex : tokenList.size() - 1;
    if (targetIdx >= 0 && targetIdx < tokenList.size()) {
      Token prev = tokenList.get(targetIdx);
      String combined = prev.value.equals(" ") ? "space2" : prev.value + "2";
      if (imageMapping.containsKey(combined)) {
        prev.value = combined;
        return;
      }
    }
  }

  if (c.equals("#")) {
    if (imageMapping.containsKey("#")) insertToken("#");
    return;
  }

  if (underscoreMode) {
    String key = "_" + c;
    if (imageMapping.containsKey(key)) insertToken(key);
  } else {
    if (imageMapping.containsKey(c)) insertToken(c);
  }
}

void handleBackspace() {
  if (tokenList.size() == 0) return;
  if (underscoreMode && rtlStartIndex >= 0 && tokenList.size() > rtlStartIndex) {
    tokenList.remove(rtlStartIndex);
  } else tokenList.remove(tokenList.size() - 1);
  if (tokenList.size() == 0) isFirstKey = true;
}

void handleEnter() {
  checkFirstKey();
  if (underscoreMode) {
    tokenList.add(new Token("ENTER", activeAlignment));
    rtlStartIndex = tokenList.size();
  } else tokenList.add(new Token("ENTER", activeAlignment));
}

void clearAll() {
  tokenList.clear();
  isFirstKey = true;
  underscoreMode = false;
  rtlStartIndex = -1;
  activeAlignment = "left";
  statusText = "Standard-Modus (Links nach Rechts)";
  notice = "";
}

void keyAction(String k) {
  if (k.equals("SPACE")) handleNewChar(" ");
  else if (k.equals("BACK")) handleBackspace();
  else if (k.equals("ENTER")) handleEnter();
  else handleNewChar(k);
}

boolean pointInRect(float px, float py, float rx, float ry, float rw, float rh) {
  return px >= rx && px <= rx + rw && py >= ry && py <= ry + rh;
}

void touchStarted() {
  updateLayoutMetrics();
  float x = mouseX, y = mouseY;

  int[] sRect = getSettingsRowRects();
  int sY = sRect[0], boxW = sRect[1], boxH = sRect[2];
  int sGap = getGap();
  int[] steps = {40, 20, 4};
  for (int i = 0; i < 3; i++) {
    int bx = margin + i * (boxW + sGap);
    int[] b = getValueButtonRects(bx, sY, boxW, boxH);
    if (pointInRect(x, y, b[0], b[1], b[2], b[3])) {
      changeSetting(i, -steps[i]);
      return;
    }
    if (pointInRect(x, y, b[4], b[5], b[6], b[7])) {
      changeSetting(i, steps[i]);
      return;
    }
  }

  int[] m = getModeLayoutMetrics();
  int row1Y = m[2], btnH = m[3], bw = m[4], mGap = m[5];
  if (y >= row1Y && y <= row1Y + btnH) {
    for (int i = 0; i < 3; i++) {
      int ax = margin + i * (bw + mGap);
      if (pointInRect(x, y, ax, row1Y, bw, btnH)) {
        if (i == 0) activeAlignment = "left";
        else if (i == 1) activeAlignment = "center";
        else activeAlignment = "right";
        return;
      }
    }
    return;
  }

  int[] e = getExportLayoutMetrics();
  int exportY = e[0], exportH = e[1], exportBW = e[2], exportGap = e[3];
  if (y >= exportY && y <= exportY + exportH) {
    for (int i = 0; i < 3; i++) {
      int ex = margin + i * (exportBW + exportGap);
      if (pointInRect(x, y, ex, exportY, exportBW, exportH)) {
        if (i == 0) exportPNG();
        else if (i == 1) exportHTML();
        else clearAll();
        return;
      }
    }
    return;
  }

  if (y >= keyboardTop) {
    int rows = keyboardLayout.length;
    int kGap = getKeyGap();
    int usableW = width - 2 * margin;
    int row = (int)((y - keyboardTop) / (keyH + kGap));
    if (row >= 0 && row < rows && (y - keyboardTop) - row * (keyH + kGap) <= keyH) {
      String[] keys = keyboardLayout[row];
      int count = 0;
      for (String s : keys) if (!s.equals("")) count++;
      if (count > 0) {
        int kw = (usableW - (count - 1) * kGap) / count;
        int col = (int)((x - margin) / (kw + kGap));
        if (col >= 0 && col < keys.length && (x - margin) - col * (kw + kGap) <= kw && !keys[col].equals("")) {
          keyAction(keys[col]);
        }
      }
    }
    return;
  }
}

void changeSetting(int which, int delta) {
  if (which == 0) editorWidth  = constrain(editorWidth  + delta, 200, 1400);
  if (which == 1) editorHeight = constrain(editorHeight + delta, 70, 700);
  if (which == 2) charSize     = constrain(charSize     + delta, 12, 300);
}

void keyPressed() {
  if (key == BACKSPACE || key == DELETE) handleBackspace();
  else if (key == ENTER || key == RETURN) handleEnter();
  else if (key == ' ') handleNewChar(" ");
  else if (key != CODED) handleNewChar(str(key));
}

void blendImageTransparent(PImage dst, PImage src, int dstX, int dstY) {
  src.loadPixels();
  dst.loadPixels();
  for (int sy = 0; sy < src.height; sy++) {
    int dy = dstY + sy;
    if (dy < 0 || dy >= dst.height) continue;
    for (int sx = 0; sx < src.width; sx++) {
      int dx = dstX + sx;
      if (dx < 0 || dx >= dst.width) continue;

      int sc = src.pixels[sy * src.width + sx];
      float sa = ((sc >>> 24) & 0xFF) / 255.0;
      if (sa <= 0.001) continue;

      int dc = dst.pixels[dy * dst.width + dx];
      float da = ((dc >>> 24) & 0xFF) / 255.0;

      int sr = (sc >> 16) & 0xFF;
      int sg = (sc >> 8) & 0xFF;
      int sb = sc & 0xFF;

      int dr = (dc >> 16) & 0xFF;
      int dg = (dc >> 8) & 0xFF;
      int db = dc & 0xFF;

      float outA = sa + da * (1.0 - sa);
      if (outA <= 0.001) continue;

      int outR = round((sr * sa + dr * da * (1.0 - sa)) / outA);
      int outG = round((sg * sa + dg * da * (1.0 - sa)) / outA);
      int outB = round((sb * sa + db * da * (1.0 - sa)) / outA);
      int outAlpha = constrain(round(outA * 255.0), 0, 255);

      dst.pixels[dy * dst.width + dx] = (outAlpha << 24) | (outR << 16) | (outG << 8) | outB;
    }
  }
  dst.updatePixels();
}

void exportPNG() {
  if (tokenList.size() == 0) {
    notice = "Bitte zuerst etwas schreiben";
    return;
  }

  try {
    int outW = max(200, editorWidth);
    int outH = max(60, editorHeight);
    PImage outImg = createImage(outW, outH, ARGB);
    outImg.loadPixels();
    Arrays.fill(outImg.pixels, color(0, 0, 0, 0));
    outImg.updatePixels();

    ArrayList<LineData> lines = makeLines();
    float yy = 15;
    for (LineData line : lines) {
      float total = measureLine(line.tokens, charSize);
      float xx = 15;
      if (line.align.equals("center")) xx = 15 + (outW - 30 - total) / 2.0;
      if (line.align.equals("right")) xx = outW - 15 - total;

      for (Token t : line.tokens) {
        if (t.value.equals("CURSOR")) continue;
        TokenMetrics tm = getTokenMetrics(t, charSize);
        PImage img = images.get(t.value);
        if (tm.isImage && img != null) {
          PImage copyImg = img.get();
          int targetW = max(1, round(tm.iw));
          int targetH = max(1, round(tm.ih));
          copyImg.resize(targetW, targetH);
          blendImageTransparent(outImg, copyImg, round(xx), round(yy + tm.yOff));
          xx += tm.adv;
        }
      }
      yy += charSize + charSize * 0.15 + 5;
    }

    String filename = "UniWriter_" + year() + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + ".png";
    File exportDir = getUniwriterImagesDir();
    String fullPath = (exportDir != null) ? new File(exportDir, filename).getAbsolutePath() : sketchPath(filename);

    outImg.save(fullPath);

    if (exportDir != null) {
      try {
        Context ctx = getActivity().getApplicationContext();
        MediaScannerConnection.scanFile(ctx, new String[]{fullPath}, new String[]{"image/png"}, null);
      } catch (Exception e) {
        // Ignorieren, falls Context nicht verfügbar
      }
    }
    notice = "PNG gespeichert unter: " + fullPath;
  } catch (Exception e) {
    notice = "PNG-Export fehlgeschlagen: " + e.getMessage();
  }
}

void exportHTML() {
  if (tokenList.size() == 0) {
    notice = "Bitte zuerst etwas schreiben";
    return;
  }

  try {
    String html = "<!DOCTYPE html>\n<html lang=\"de\"><head><meta charset=\"UTF-8\"><title>UniWriter Export</title></head><body style=\"background:#f4f6f9;padding:20px\">\n";
    html += "<div style=\"background:white;padding:15px;width:" + editorWidth + "px;min-height:" + editorHeight + "px;font-size:0\">\n";
    ArrayList<LineData> lines = makeLines();
    for (LineData line : lines) {
      html += "<div style=\"height:" + charSize + "px;white-space:nowrap;text-align:" + line.align + ";margin-bottom:" + (charSize * .15) + "px\">";
      for (Token t : line.tokens) {
        if (t.value.equals("CURSOR")) continue;
        if (!images.containsKey(t.value)) continue;
        String file = imageMapping.get(t.value);
        if (file == null) continue;
        TokenMetrics tm = getTokenMetrics(t, charSize);
        if (!tm.isImage) continue;
        html += "<img src=\"" + file + "\" style=\"width:" + tm.iw + "px;height:" + tm.ih + "px;vertical-align:top;position:relative;top:" + tm.yOff + "px;margin-right:" + max(0.0, tm.adv - tm.iw) + "px\">";
      }
      html += "</div>\n";
    }
    html += "</div></body></html>";

    String filename = "UniWriter_" + year() + nf(month(), 2) + nf(day(), 2) + "_" + nf(hour(), 2) + nf(minute(), 2) + nf(second(), 2) + ".html";
    File exportDir = getUniwriterImagesDir();
    File outFile = (exportDir != null) ? new File(exportDir, filename) : new File(sketchPath(filename));
    String fullPath = outFile.getAbsolutePath();

    BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(new FileOutputStream(outFile), "UTF-8"));
    try {
      writer.write(html);
    } finally {
      writer.close();
    }

    if (exportDir != null) {
      try {
        Context ctx = getActivity().getApplicationContext();
        MediaScannerConnection.scanFile(ctx, new String[]{fullPath}, new String[]{"text/html"}, null);
      } catch (Exception e) {
        // Ignorieren, falls Context nicht verfügbar
      }
    }
    notice = "HTML gespeichert unter: " + fullPath;
  } catch (Exception e) {
    notice = "HTML-Export fehlgeschlagen: " + e.getMessage();
  }
}
