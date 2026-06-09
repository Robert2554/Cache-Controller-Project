# Proiect Cache Controller

## Descrierea Proiectului
Acest proiect constă în proiectarea și simularea (în limbajul Verilog) a unei memorii cache de **32 KiB, 4-way set associative**, având blocuri de **8 cuvinte** și cuvinte de **32 de biți**. Dimensiunea memoriei principale este de **8 MiB**, iar unitatea adresabilă este cuvântul. Memoria cache este proiectată cu politicile **write-back**, **write-allocate** și utilizează o politică de înlocuire de tip **LRU (Least Recently Used)**.

## Arhitectura și Parametrii Sistemului
Pentru a respecta cerințele de mai sus, sistemul a fost dimensionat folosind următorii parametri:
* **Capacitate Totală Cache:** 32 KiB
* **Asociativitate:** 4-Way Set Associative (4 căi pe fiecare set)
* **Dimensiune Bloc (Block Size):** 8 cuvinte (256 biți) per linie de cache
* **Dimensiune Cuvânt (Word Size):** 32 biți
* **Capacitate Memorie Principală:** 8 MiB
* **Politica de Scriere (Write Policy):** Write-Back & Write-Allocate
* **Politica de Înlocuire (Eviction Policy):** LRU (Least Recently Used)

## Structura Proiectului
* `src/` — Conține fișierele sursă Verilog cu implementarea logică a controlerului de cache, FSM-ului (Finite State Machine) și a memoriei principale.
* `tb/` — Conține fișierul testbench utilizat pentru injectarea stimulilor (cereri de citire/scriere către adrese specifice) și validarea comportamentului.

## Simulare și Forme de Undă (Waveforms)
Proiectul a fost simulat și validat cu succes. În timpul simulărilor s-a urmărit corectitudinea mecanismului de mapare a adreselor (Tag, Index, Offset), tranziția corectă a stărilor în caz de Hit/Miss și actualizarea memoriei principale.

Mai jos se regăsește captura de ecran cu semnalele de control, adresele și magistralele de date în timpul rulării testbench-ului:

<img width="1393" height="455" alt="f262f2c3-89ff-467e-8c75-69dcf43a43d8" src="https://github.com/user-attachments/assets/b1b5727c-b89c-4dbc-8c60-209a19d8179c" />

### 🔍 Analiza Formelor de Undă
Imaginea de mai sus ilustrează comportamentul dinamic al semnalelor din interiorul controlerului în timpul execuției testelor. Câteva aspecte esențiale vizibile pe grafic:

* **Cache Miss & Fetch din Memorie:** Când procesorul cere o adresă care nu se află în cache (de exemplu, prima citire la adresa `00004` sau `00008`), semnalul `hit` rămâne la valoarea `0`. Controlerul inițiază o citire din memoria principală. După scurgerea ciclilor de latență, blocul complet de 256 de biți este adus pe magistrala `mdin`.
* **Cache Hit Instantaneu:** Atunci când se accesează o adresă aferentă unui bloc deja existent în cache (de exemplu, adresa `00005` imediat după `00004`, sau `00009` după `00008`), semnalul `hit` devine imediat `1`. Cuvântul specific de 32 de biți este extras pe baza offset-ului și trimis direct pe magistrala de ieșire `cdout`, fără timpi morți de așteptare.
* **Maparea Seturilor:** Evoluția semnalului `caddress` arată trecerea secvențială prin adrese calculate pentru a forța maparea în seturi diferite (Set 0, Set 1, Set 2 și Set 255), validând astfel logica de feliere a adresei (Tag, Index, Offset).


*(Notă: Pentru a vedea semnalele, deschideți proiectul în ModelSim/QuestaSim și încărcați fișierul testbench în fereastra Wave).*

## Instrucțiuni de Rulare
1. Deschideți mediul de simulare (ModelSim).
2. Compilați toate fișierele `.v` din directoarele `src/` și `tb/`.
3. Porniți simularea pe fișierul de top (Testbench-ul).
4. Adăugați semnalele de interes în fereastra "Wave".
5. Rulați simularea completă folosind comanda `run -all`.
