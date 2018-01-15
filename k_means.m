%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% K-Means clustering algorithm implementation in MATLAB    %
%                                                          %
% Author: Ata Niyazov                                      %
% Work address: Kocaeli University                         %
% Website: http://bilgisayar.kocaeli.edu.tr/               %
% January 2018; Last revision: 12-January-2018             %
%                                                          %
% Kocaeli University (C) Copyright 2018.                   %
% All rights reserved.                                     %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%------------- BEGIN CODE --------------

% ekran ve bellek on temizleme
close all ; clear all ; clc ;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        Dosya tanimlama       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% dosya lokasyonu ve ismi
filename = 'iris/iris.data';

% dosya icerik formati
formatSpec = '%f,%f,%f,%f,%s';

% sinif etinin sutun numarasi
class_column = 5;
% Not: sinif etikitini son
% sutun saklamasi beklenmektedir
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% dosya acma islemi
fileID = fopen(filename);

% dosya veri setini hucre verisine donusturme
dataset_cell = textscan(fileID,formatSpec);

% acilmis dosya kapatma
fclose(fileID);

% hucre verisinden agirliklari elde etme
dataInputs = cell2mat(dataset_cell(1:class_column-1));

% hucre verisinden sinif etiketlerini elde etme
dataTargets = dataset_cell{class_column};

% K sayisini sinif etiketinden elde etme
k = numel(unique(dataTargets));

% kMeans algoritmasini baslat
[means, dataInputsK] = kMeans(dataInputs, k);

% Elde edilen kume merkezlerini yazdir
means
% Her bir verinin hangi kume merkezine ait bilgisini yazdir
dataInputsK

% K veri sayisi elde etme
dataInputsKLength = size(dataInputsK,1);

for ik = 1:k
    % Kume merkezine ait veri miktari
    dataInputsKCount = 0;
    for dataIndexK = 1:dataInputsKLength
        if dataInputsK(dataIndexK) == ik
            % Kume merkezine ait veri miktarini 1 arttir
            dataInputsKCount = dataInputsKCount + 1;
        end
    end
    % Veri miktarini yazdir
    dataInputsKCount
end

% kMeans algoritmasi
% dataInputs: veri seti
% k: istenilen k tane kume
% means: kume merkezleri
% dataInputsK: veri setindeki verilerin hangi kume merkezine ait
function [means, dataInputsK] = kMeans(dataInputs,k)
% Kume merkezleri (means)
means = [];
% Veri setinin veri sayisi elde etme
dataInputsLength = size(dataInputs,1);

% Veri setindeki verilerin ait oldugu kume merkezler bilgisi
dataInputsK = [];

% Veri setinin veri sayisi ve girilen k degeri 0'dan buyuk ise
% ve veri setinin veri sayisi girilen k degerine esit veya buyuk ise
if (dataInputsLength > 0) && (k > 0) && (dataInputsLength >= k)
    
    % Uretilecek rastgele sayilarin saklanak dizisi
    indexArray = [];
    % K tane rastgele baslangic kume merkezlerin secimi
    for ik = 1:k
        while true
            % Veri setinin uzunlugu kadar rastgele sayi uretimi
            index = randIndex(dataInputsLength);
            % Ayni rastgele sayi onceden uretildimi
            if ~ismember(index, indexArray)
                % Uretilmis rastgele sayini diziye atama
                indexArray = [indexArray index];
                % Baslangic kume merkezi olarak veri setinden sec
                means = [means; dataInputs(index,:)];
                % Rastgele sayi uretimini sonlandir
                break
            end
            % Ayni rastgele sayi onceden uretilmisse
            % bi daha rasgele sayi uret
        end
    end
    
    % % Islem iterasyon sayaci
    % iteration = 0;
    
    % Kume merkezlerini guncelleme dongusu
    while true
        % % Iterasyon sayacini bir artirma
        %iteration = iteration + 1;
        
        % Veri setindeki verilerin ait oldugu kume merkezler bilgisini
        % sifirlama
        dataInputsK = zeros(dataInputsLength,1);
        
        % Veri setindeki veri hangi kume merkezinin elemani
        for dataIndex = 1:dataInputsLength
            % Veri setinden veri alma
            data = dataInputs(dataIndex,:);
            % Secilmis nokta ile her mean noktasi arasindaki oklid uzaklik hesabi
            meansDist = [];
            for meansIndex = 1:k
                % Veri setindeki her nokta ile kume merkezleri arasindaki uzaklik hesabi
                meansDist = [meansDist euclid_dist(means(meansIndex,:), data)];
            end
            % NaN : en kucuk uzaklik degeri ilgilendirmiyou
            % I : en kucuk uzakligin dizideki indisi
            [NaN,I] = min(meansDist);
            % Verinin hangi k kume merkezine ait
            dataInputsK(dataIndex) = I;
            %dataInputsK(dataIndex) = minElem(meansDist);
        end
        
        % Hesaplama ile elde edilecek yeni kume merkezleri (means)
        meansTemp = zeros(size(means));
        
        % Kumedeki verilerden yeni kume merkezlerinin elde edilmesi
        for ik = 1:k
            % Kume merkezine ait veri miktari
            dataInputsKCount = 0;
            for dataIndex = 1:dataInputsLength
                % Verisetindeki veri secilmis kume merkezine ait mi?
                if dataInputsK(dataIndex) == ik
                    % Veri setinden veri alma
                    data = dataInputs(dataIndex,:);
                    % Kumedeki her verinin agirliklarini topla
                    meansTemp(ik,:) = (meansTemp(ik,:) + data);
                    % Kume merkezine ait veri miktarini 1 arttir
                    dataInputsKCount = dataInputsKCount + 1;
                end
            end
            % Kume merkezine ait veri mevcut mu?
            if dataInputsKCount ~= 0
                % Kume merkezlerine ait veri agirliklarinin toplaminin veri
                % miktarina bolumu
                meansTemp(ik,:) = (meansTemp(ik,:) ./ dataInputsKCount);
            else
                % Kume merkezine ait veri yok ise
                % Not: algoritmanin bu kismina hic ulasmamasi beklenmektedir
                disp('kMeans(): one of the clusters containing no data.')
                meansTemp
                means
            end
        end
        
        % Kume merkezlerinin guncellemesinin bitme kontrolu
        % Kume merkezleri ayni mi?
        if means == meansTemp
            %means
            %iteration
            %dataInputsK
            
            % Kume merkezlerinin guncellemesini durdur
            break
        else
            % Kume merkezleri ayni degil ise kume merkezlerini guncelle
            means = meansTemp;
        end
    end
else
    % Veri setinin veri sayisi 0 (veri yok) ise hata mesajini ver
    if dataInputsLength <= 0
        disp('kMeans(): dataInputs containing no data.')
    end
    
    % k degeri 0 veya 0'dan kucuk ise hata mesajini ver
    if k <= 0
        disp('kMeans(): k value must be positive and non-zero value.')
    end
    
    % Veri setinde girilen k degerinden az veri iceriyor ise hata mesajini
    % ver
    if dataInputsLength < k
        disp('kMeans(): k value must be less than or equal to dataInputsLength.')
    end
    
    % kMeans fonksiyon sonuclari means ve dataInputsK
    % bos dizi olarak geri dondurilecektir
end
end

% [1,length] arasinda rastgele sayi ureten fonksiyon
function index = randIndex(length)
% Giris 0'dan farkli ve pozitif sayi beklenmektedir
if length > 0
    % [1,length] araliginda rastgele sayi uret
    index = randi([1,length],1);
else
    % Giris 0 veya negatif sayi ise hata mesajini ver
    disp('randIndex(): length must be positive and non-zero value.');
    % Fonksiyondan 0 geri donur
    index = 0;
end
end

% Verilen dizinin en kucuk elamaninin index'ini donduren fonksiyon
function index = minElem(array)
% Dizinin eleman sayisini elde etme
arraySize = size(array,2);
% Dizinin eleman sayisi 0'dan farkli ise
if arraySize > 0
    % Baslangicta en kucuk eleman ilk eleman olarak belirleniyor
    index = 1;
    smallest = array(index);
    % Dizinin elemanlarini gezme
    for i = 1:arraySize
        % En kucuk deger dizinin i. eleman degerinden buyuk ise
        if smallest > array(i)
            % En kucuk deger dizinin eleman degeri olarak belirleniyor
            smallest = array(i);
            % Yeni en kucuk elemanin index'i kayit ediliyor
            index = i;
        end
    end
else
    % Dizinin eleman sayisi 0 ise hata mesajini ver
    disp('minElem(): array size must be higher than 0.')
    % Dizinin en kucuk elemani 0. index olarak belirlenir
    index = 0;
end
end

% Euclidean distance
% Verilen iki nokta arasinda oklid uzakligi bulma fonksiyonu
% P, Q: Arasinda oklid uzaklik hesabi yapilacak noktalar
% Noktalarin kac boyutta oldugu onemli degil
% Not: Noktalar ayni boyutlarda olmasi beklenmektedir
% Aksi taktirde realmax degeri elde edilir (olasi en buyuk deger)
function dist = euclid_dist(P,Q)
% Verilen noktalar ayni boyutta mi
if (isequal(size(P),size(Q))) && (size(P,1) == 1 && size(Q,1) == 1)
    % Noktalarin koordinat sayisi kac
    dim = size(P,2);
    % Hesaplama islemi
    dist = 0;
    for i = 1:dim
        % Noktalarin koordinatsal islemi
        dist = dist + (Q(i) - P(i))^2;
    end
    % Sonucun kare kokunu alma
    dist = sqrt(dist);
else
    % Verilen noktalar ayni boyutta degil ise hata mesajini ver.
    disp('euclid_dist(): P and Q are not the same size or not 1 to n arrays (vectors).');
    % Verilen noktalarin arasindaki uzaklik en buyuk double precision
    % float olarak belirle
    dist = realmax;
end
end

%------------- END OF CODE --------------