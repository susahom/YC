
#define PY_SSIZE_T_CLEAN
#define NPY_NO_DEPRECATED_API NPY_1_7_API_VERSION


#include "opencv2/opencv.hpp"
#include "opencv2/core/utility.hpp"

#include <tchar.h>
#include <windows.h>
#include <atlbase.h>
#include <atlstr.h>
#include <atltime.h>


#include "Python.h"
#include "numpy/ndarraytypes.h"
#include "numpy/arrayobject.h"

#include <iostream>
#include <vector>
#include <memory>

#include <boost/algorithm/string/classification.hpp>
#include <boost/algorithm/string/split.hpp>

#include "CaptureSender.h"
#include "ycapture.h"

#ifdef _DEBUG
#	pragma comment(lib, "opencv_core343d.lib")
#	pragma comment(lib, "ycapture.lib")
#	pragma comment(lib, "ycaptureclient.lib")
#	pragma comment(lib, "python36.lib")
#	pragma comment(lib, "python3.lib")
#	pragma comment(lib, "opencv_highgui343d.lib")
#	pragma comment(lib, "opencv_video343d.lib")
#	pragma comment(lib, "opencv_videoio343d.lib")
#	pragma comment(lib, "opencv_objdetect343d.lib")
#	pragma comment(lib, "opencv_imgproc343d.lib")
#	pragma comment(lib, "opencv_imgcodecs343d.lib")
#else
#	pragma comment(lib, "opencv_core343.lib")
#	pragma comment(lib, "ycapture.lib")
#	pragma comment(lib, "ycaptureclient.lib")
#	pragma comment(lib, "python36.lib")
#	pragma comment(lib, "python3.lib")
#	pragma comment(lib, "opencv_highgui343.lib")
#	pragma comment(lib, "opencv_video343.lib")
#	pragma comment(lib, "opencv_videoio343.lib")
#	pragma comment(lib, "opencv_objdetect343.lib")
#	pragma comment(lib, "opencv_imgproc343.lib")
#	pragma comment(lib, "opencv_imgcodecs343.lib")
#endif

namespace t23 {
	class Util {
	public:
		static void convertTstrToCvString(LPCTSTR src, cv::String& cvStr) {
			std::unique_ptr<char[]> tmpStr = convertTstrToMultiByte(src);
			cvStr.clear();
			cvStr = tmpStr.get();
		}

		static std::unique_ptr<char[]> convertTstrToMultiByte(LPCTSTR src){
			size_t tmpLen = 0;
			tmpLen = ::WideCharToMultiByte(CP_THREAD_ACP, 0, src, -1, nullptr, 0, nullptr, nullptr);
			 std::unique_ptr<char[]> tmpStr(new char[tmpLen]);
			if (tmpStr.get()) {
#pragma warning(push)
#pragma warning(disable: 4267)
				tmpLen = ::WideCharToMultiByte(CP_THREAD_ACP, 0, src, (int)::wcslen(src) + 1, tmpStr.get(), tmpLen, nullptr, nullptr);
#pragma warning(pop)
			}
			return std::move(tmpStr);
		}
	};

	enum class CapMode {
		Undefined   = -1,
		FaceCollect = 1,
		FaceDetect  = 2
	};

	class FaceCollector {
	protected:
		static constexpr double magicScaleFactor = 1.1;
		static constexpr int    minNeighbors = 3;
		static constexpr int    minResolution = 100;
		static constexpr size_t maxDetectionCount = 21;
		static constexpr DWORD  detectBetween = 500;

		int oldcounts = 0;

		const char* defaultModelFile=u8R"(.\haarcascade_frontalface_alt2.xml)";
		const  cv::Size         minFaceSize;

		cv::CascadeClassifier* cascadeClassifier = nullptr;

		std::vector<cv::Rect> detected;
		std::vector<int>      levels;
		std::vector<double>   weights;
		std::vector<cv::Mat*>  faces;

	public:
		FaceCollector(LPCTSTR modelFile = nullptr) :
			minFaceSize(minResolution, minResolution) {
			cv::String cascadeFile;
			if (modelFile) {
				Util::convertTstrToCvString(modelFile, cascadeFile);
			}
			else {
				cascadeFile = defaultModelFile;
			}
			cascadeClassifier = new cv::CascadeClassifier();
			if (!cascadeClassifier->load(cascadeFile)) {
				assert(false);
				return;
			}
		}

		~FaceCollector() {
			if (cascadeClassifier) {
				delete cascadeClassifier;
				cascadeClassifier = nullptr;
			}
		}

		bool isEnough() {
			return (faces.size() >= maxDetectionCount);
		}

		const DWORD Between() {
			return detectBetween;
		}

		bool detectFace(const cv::Mat& image, bool extractFace = true, bool resizeExtractedFace = true) {
			assert(cascadeClassifier != nullptr);

			cv::Mat image_gray;
			cv::cvtColor(image, image_gray, cv::COLOR_BGR2GRAY);
			try {
				cascadeClassifier->detectMultiScale(image_gray, detected,magicScaleFactor,minNeighbors);
			}
			catch (std::exception e) {
				std::cerr << __FILE__ << ":" << __FUNCTION__ << e.what() << std::endl;
			}

			if (detected.size() == 0) {
				return false;
			}

			if (extractFace) {
#pragma warning(push)
#pragma warning(disable: 26444)
				std::for_each(detected.begin(), detected.end(), [this, image, resizeExtractedFace](cv::Rect& faceArea) {
#pragma warning(pop)
					auto face = new cv::Mat(image, faceArea);
					cv::Size faceSize;
					faceSize.width = faceArea.width;
					faceSize.height = faceArea.height;
					if (resizeExtractedFace) {
						cv::resize(*face, *face, faceSize, this->minFaceSize.width/faceSize.width, this->minFaceSize.height/faceSize.height);
					}
					faces.push_back(face);
					std::cout << "detected(" << faces.size() << ")" << std::endl;
				});
				detected.resize(static_cast<size_t>(0));
			}
			return true;
		}
		std::vector<cv::Mat*>& getFaceList() { return faces; }
	};

	class FaceLearningDriver {
	protected:
		static constexpr char    constantName[]      = "faces";
		static constexpr char    learningPython[]    = "train";
		static constexpr char    learningFunction[]  = "begin_training";

		static constexpr char    DetectorPython[]    = "detect";
		static constexpr char    DetectorSetup[]     = "setup_detector";
		static constexpr char    DetectorFunction[]  = "detect_and_mark";
		static constexpr char    DetectorShutdown[]  = "close_tfsession";

		LPCTSTR trainDataDir = _T("train");
		LPCTSTR testDataDir  = _T("test");

		std::vector<cv::Mat*>& faceList;
		PyObject*              tfSessInfo     = nullptr;
		PyObject*              pyModule       = nullptr;
		int                    dimTFSessInfo  = 0;
		PyObject*              tfSessInfoCopy = nullptr;


	private:
		int learnedCount = 0;

	private:
		void prepareDirectory(LPCTSTR targetName, CString& saveDir) {
			size_t cwdLength = 0;
			TCHAR* cwdName = nullptr;
			CString path;
			CString newPath;

			if (saveDir.GetLength() == 0) {
				cwdLength = ::GetCurrentDirectory(0, nullptr);
				cwdName = new TCHAR[cwdLength];
#pragma warning(push)
#pragma warning(disable:4267)
				cwdLength = GetCurrentDirectory(cwdLength, cwdName);
#pragma warning(pop)
				path = cwdName;
				path += _T("\\");
			}
			else {
				path  = saveDir;
				if (path.GetAt(path.GetLength() - 1) != _T('\\')) {
					path += ("\\");
				}
			}
			saveDir = path;

			const LPCTSTR targList[] = { trainDataDir, testDataDir };
			for (auto trg : targList) {
				newPath  = path + constantName;
				newPath += _T("\\");
				newPath += trg;
				newPath += _T("\\");
				newPath += targetName;
				prepareDirAux(newPath);
			}
		}

		void prepareDirAux(CString& path) {
			std::vector<CString> splitPath;
			int curPos = 0;
			CString token = _T("");
			CString concatPath = _T("");

			token = path.Tokenize(_T("\\"), curPos);
			while (token != _T("")) {
				splitPath.push_back(CString(token));
				token = path.Tokenize(_T("\\"), curPos);
			}
			for (auto next : splitPath) {
				concatPath += next;
				if (!PathFileExists(concatPath)) {
					if (!CreateDirectory(concatPath, nullptr)) {
						assert(false);
					}
				}
				concatPath += _T("\\");
			}
		}

		PyObject* pyKicker(const char* funcName, PyObject* pyArgs, bool decrefArgs=true) {
			PyObject*      pyFunc  = nullptr;
			PyObject*      pyValue = nullptr;

			if (pyModule) {
				pyFunc = PyObject_GetAttrString(pyModule, funcName);
				if (pyFunc && PyCallable_Check(pyFunc)) {
					pyValue = (PyObject*)PyObject_CallObject(pyFunc, pyArgs);
					if (decrefArgs) {
						Py_DECREF(pyArgs);
					}
				}
				Py_XDECREF(pyFunc);
			}
			else {
				PyErr_Print();
			}
			return pyValue;
		}

#pragma warning(push)
#pragma warning(disable:4715)
		int _pyarray_init() {
			import_array();
		}
#pragma warning(pop)

	public:
		FaceLearningDriver(t23::CapMode capmode, std::vector<cv::Mat*>& faceListFrom) :
			faceList(faceListFrom) {
			PyObject* pyName = nullptr;

			Py_Initialize();
			PyObject* sys  = PyImport_ImportModule("sys");
			PyObject* path = PyObject_GetAttrString(sys, "path");
			PyList_Append(path, PyUnicode_DecodeFSDefault(".\\"));
			PyList_Append(path, PyUnicode_DecodeFSDefault("D:\\CoE_sasa\\ICF_AutoCapsule_disabled\\backendFlow\\"));
			PyList_Append(path, PyUnicode_DecodeFSDefault("D:\\CoE_sasa\\ICF_AutoCapsule_disabled\\ycapture-src-0.1.1\\ycapture\\WithOpenCV\\"));
			switch (capmode) {
			case t23::CapMode::FaceCollect:
				pyName = PyUnicode_DecodeFSDefault(learningPython);
				pyModule = PyImport_Import(pyName);
				Py_DECREF(pyName);
				break;

			case t23::CapMode::FaceDetect:
				_pyarray_init();
				pyName = PyUnicode_DecodeFSDefault(DetectorPython);
				pyModule = PyImport_Import(pyName);
				Py_DECREF(pyName);
				break;
			default:
				pyModule = nullptr;
				break;
			}
		}

		~FaceLearningDriver() {
			Py_DECREF(pyModule);
			Py_Finalize();
		}

		void saveFaceImageToFile(LPCTSTR targetName, LPCTSTR baseDir = nullptr) {
			const CString now = (CTime::GetCurrentTime()).Format(_T("%Y%m%d%H%M%S"));
			CString targetDir;
			CString fileName;
			CString fullPath;
			LPCTSTR targDir = nullptr;

			cv::String fullPathCvStr;

			if (baseDir) {
				targetDir = baseDir;
			}

			prepareDirectory(targetName, targetDir);

			int cnt = 0;
			for (auto it = faceList.begin(); it != faceList.end();it++,cnt++) {
				auto newIt = it;
				if (++newIt != faceList.end()) {
					targDir = trainDataDir;
				}
				else {
					targDir = testDataDir;
				}
				fullPath  = targetDir;
				fullPath += constantName;
				fullPath += _T("\\");
				fullPath += targDir;
				fullPath += _T("\\");
				fullPath += targetName;
				fullPath += _T("\\");
				fileName.Format(_T("%s-%05d.jpg"), (LPCTSTR)now, cnt);
				fullPath += fileName;
				Util::convertTstrToCvString(fullPath, fullPathCvStr);
				try {
					cv::imwrite(fullPathCvStr, static_cast<cv::InputArray>(**it));
				}
				catch (std::exception e) {
					std::cout << e.what() << std::endl;
					assert(false);
				}
			}
		}

		void kickFaceLearningPython(LPCTSTR targetDir = nullptr) {
			PyObject* pyArgs = PyTuple_New(1);
			PyObject* pyValue = nullptr;
			{
				std::unique_ptr<char[]> cnvTmpBuf;
				if (targetDir) {
					cnvTmpBuf = Util::convertTstrToMultiByte(targetDir);
				}
				else {
					size_t bsize = ::GetCurrentDirectory(0, nullptr);
					std::unique_ptr<TCHAR[]> bufCwd(new TCHAR[bsize]);
#pragma warning(push)
#pragma warning(disable: 4267)
					::GetCurrentDirectory(bsize, bufCwd.get());
#pragma warning(pop)
					cnvTmpBuf = Util::convertTstrToMultiByte(bufCwd.get());
				}
				pyValue = PyUnicode_DecodeFSDefault(cnvTmpBuf.get());
				PyTuple_SetItem(pyArgs, 0, pyValue);
				PyObject* pyRet = pyKicker(learningFunction, pyArgs);
				if (pyRet) {
					Py_DECREF(pyRet);
					pyValue = nullptr;
				}
			}
			Py_DECREF(pyArgs);
		}

		void kickDetectorSetup(LPCTSTR targetDir = nullptr) {

			PyObject* pyArgs = PyTuple_New(1);
			PyObject* pyValue = nullptr;
			PyObject* pyRet = nullptr;
			{
				std::unique_ptr<char[]> cnvTmpBuf;
				if (targetDir) {
					cnvTmpBuf = Util::convertTstrToMultiByte(targetDir);
				}
				else {
					size_t bsize = ::GetCurrentDirectory(0, nullptr);
					std::unique_ptr<TCHAR[]> bufCwd(new TCHAR[bsize]);
#pragma warning(push)
#pragma warning(disable: 4267)
					::GetCurrentDirectory(bsize, bufCwd.get());
#pragma warning(pop)
					cnvTmpBuf = Util::convertTstrToMultiByte(bufCwd.get());
				}
				pyValue = PyUnicode_DecodeFSDefault(cnvTmpBuf.get());
				PyTuple_SetItem(pyArgs, 0, pyValue);
				pyRet = pyKicker(DetectorSetup, pyArgs,false);

				PyObject* label_dict = nullptr;
				PyObject* names = nullptr;
				PyObject* cascade = nullptr;
				PyObject* keep_prob = nullptr;
				PyObject* y_conv = nullptr;
				PyObject* x = nullptr;
				PyObject* sess = nullptr;
				PyArg_ParseTuple(pyRet, "OOOOOOO", &label_dict, &names, &cascade, &keep_prob, &y_conv, &x, &sess);
				tfSessInfoCopy = PyTuple_New(8);
				PyTuple_SetItem(tfSessInfoCopy, 0, label_dict);
				PyTuple_SetItem(tfSessInfoCopy, 1, names);
				PyTuple_SetItem(tfSessInfoCopy, 2, cascade);
				PyTuple_SetItem(tfSessInfoCopy, 3, keep_prob);
				PyTuple_SetItem(tfSessInfoCopy, 4, y_conv);
				PyTuple_SetItem(tfSessInfoCopy, 5, x);
				PyTuple_SetItem(tfSessInfoCopy, 6, sess);
			}
			Py_DECREF(pyArgs);
		}

		cv::Mat kickFaceDetectAndMark(cv::Mat& captured) {
			PyArrayObject* pyRet = nullptr;
			int channels = captured.channels();
			int dims     = captured.dims + 1;
			npy_intp dimensions[3] = { captured.rows, captured.cols, channels };
			PyObject* pImg = PyArray_SimpleNewFromData(dims, &dimensions[0], NPY_UINT8, captured.data);
			PyTuple_SetItem(tfSessInfoCopy, 7, pImg);
			pyRet      = (PyArrayObject*)pyKicker(DetectorFunction, tfSessInfoCopy, false);
			if (pyRet) {
				int   r1 = PyArray_NDIM(pyRet);
#pragma warning(push)
#pragma warning(disable: 4244)
				long  rows = PyArray_SHAPE(pyRet)[0];
				long  cols = PyArray_SHAPE(pyRet)[1];
				long  r2 = PyArray_SHAPE(pyRet)[2];
#pragma warning(pop)
				void* rawframe = PyArray_DATA(pyRet);
				cv::Mat newframe(rows, cols, CV_8UC3, rawframe);
				Py_DECREF(pyRet);
				return newframe;
			}
			else {
				return captured;
			}
		}

		void kickDetectorShutdown() {
			if (tfSessInfo) {
				PyObject* pyRet = nullptr;
				pyRet = pyKicker(DetectorShutdown, (PyObject*)tfSessInfo);
				Py_DECREF(pyRet);
			}
		}
	};

	class ModCapture {
	private:
		cv::VideoCapture cap;
		::CaptureSender  capSender;
		std::function<bool(cv::Mat&, LPCTSTR)>  handler;
		std::unique_ptr<FaceCollector> faceCollector;
		std::unique_ptr<FaceLearningDriver> faceLearning;

		void initialize(CapMode mode, bool skipCapturing=false) {
			faceCollector.reset(new FaceCollector());
			faceLearning.reset(new FaceLearningDriver(mode, faceCollector->getFaceList()));
			switch (mode) {
			case CapMode::FaceCollect:
				handler = [this,skipCapturing](cv::Mat& captured, LPCTSTR targetName) {
					try {
						faceCollector->detectFace(captured);
						
					}
					catch (std::exception e) {

					}
					if (skipCapturing || faceCollector->isEnough()) {
						faceLearning->saveFaceImageToFile(targetName);
						faceLearning->kickFaceLearningPython();
						return false;
					}
					else {
						::Sleep(faceCollector->Between());
						return true;
					}
				};
				break;
			case CapMode::FaceDetect:
				faceLearning->kickDetectorSetup();
				handler = [this](cv::Mat& captured, LPCTSTR ignoredOption = nullptr) {
					unsigned long long tick = ::GetTickCount64();
					cv::Mat output = faceLearning->kickFaceDetectAndMark(captured);
					//outputを上下左右反転させる20191206sasa
					cv::Mat output_filped;//出力Mat
					cv::flip(output, output_filped, -1);//上下左右反転
					capSender.Send(::GetTickCount64(), output_filped.cols, output_filped.rows, output_filped.data);
					//capSender.Send(::GetTickCount64(),output.cols, output.rows, output.data);
					int wkey = cv::waitKey(1000 / 15);
					if (wkey >= 0) {
						return false;
					}else{
						return true;
					}
				};
				break;
			default:
				break;
			}
		}

	public:

		ModCapture(int deviceId = 0, CapMode mode = CapMode::FaceDetect, bool isSkipCapturing=false) : capSender(CS_SHARED_PATH, CS_EVENT_WRITE, CS_EVENT_READ) {
			cv::Mat frame;
			cap.open(deviceId);
			initialize(mode, isSkipCapturing);
		}

		ModCapture(LPCTSTR fileName, CapMode mode = CapMode::FaceDetect, bool isSkipCapturing=false) : capSender(CS_SHARED_PATH, CS_EVENT_WRITE, CS_EVENT_READ) {
			assert(fileName != nullptr);
			cv::String tmpstr;
			Util::convertTstrToCvString(fileName, tmpstr);
			cap.open((const cv::String&)tmpstr);
			initialize(mode, isSkipCapturing);
		}

		~ModCapture() {
			dispose();
		}

		int startCapture(LPCTSTR targetName=nullptr, bool isDisplaying = false) {
			cv::Mat frame;

			if (!cap.isOpened()) {
				throw new std::exception("[ERROR] Data Source is not prepared yet");
			}

			while (cap.read(frame)) {
				if (isDisplaying) {
					cv::imshow("win", frame);
					cv::waitKey(20);
				}
				if (!handler(frame, targetName)) {
					break;
				}
			}
			return 0;
		}

		int dispose() {
			if (cap.isOpened()) {
				cap.release();
			}
			return 0;
		}
	};

	struct option {
		LPCTSTR name;
		int     has_arg;
		int*    flag;
		int     val;
	};

	class GetOpts {
	private:
		int argc = 0;
		TCHAR** argv = nullptr;
		LPTSTR optarg = nullptr;
		LPCTSTR optstring = nullptr;
		int optind = 1;
		int opterr = 1;
		int optopt = 0;

		int postpone_count = 0;
		int nextchar = 0;

		void postpone(int index) {
			TCHAR** nc_argv = argv;
			TCHAR* p = nc_argv[index];
			int j = index;
			for (; j < argc - 1; j++) {
				nc_argv[j] = nc_argv[j + 1];
			}
			nc_argv[argc - 1] = p;
		}

		int postpone_noopt(int index) {
			int i = index;
			for (; i < argc; i++) {
				if (*(argv[i]) == _T('-')) {
					postpone(index);
					return 1;
				}
			}
			return 0;
		}

		int _getopt_(const option* longopts, int* longindex)
		{
			while (1) {
				TCHAR c = _T('\0');
				const TCHAR* optptr = nullptr;
				if (optind >= argc - postpone_count) {
					c = 0;
					optarg = 0;
					break;
				}
				c = *(argv[optind] + nextchar);
				if (c == _T('\0')) {
					nextchar = 0;
					++optind;
					continue;
				}
				if (nextchar == 0) {
					if (optstring[0] != _T('+') && optstring[0] != _T('-')) {
						while (c != _T('-')) {
							if (!postpone_noopt(optind)) {
								break;
							}
							++postpone_count;
							c = *argv[optind];
						}
					}
					if (c != _T('-')) {
						if (optstring[0] == _T('-')) {
							optarg = argv[optind];
							nextchar = 0;
							++optind;
							return 1;
						}
						break;
					}
					else {
						if (_tcscmp(argv[optind], _T("--")) == 0) {
							optind++;
							break;
						}
						++nextchar;
						if (longopts != 0 && *(argv[optind] + 1) == _T('-')) {
							TCHAR const* spec_long = argv[optind] + 2;
							TCHAR const* pos_eq = _tcschr(spec_long, _T('='));
#pragma warning(push)
#pragma warning(disable:4267)
							int   spec_len = (pos_eq == NULL ? _tcslen(spec_long) : pos_eq - spec_long);
#pragma warning(pop)
							int   index_search = 0;
							int   index_found = -1;
							const struct option* optdef = 0;
							while (longopts->name != 0) {
								if (_tcsncmp(spec_long, longopts->name, spec_len) == 0) {
									if (optdef != 0) {
										if (opterr) {
											std::wcerr<< L"ambiguous option: " << spec_long << std::endl;
										}
										return _T('?');
									}
									optdef = longopts;
									index_found = index_search;
								}
								longopts++;
								index_search++;
							}
							if (optdef == 0) {
								if (opterr) {
									std::wcerr<< L"no such a option: " << spec_long << std::endl;
								}
								return _T('?');
							}
							switch (optdef->has_arg) {
							case 0:
								optarg = 0;
								if (pos_eq != 0) {
									if (opterr) {
										std::wcerr << L"no argument for " << optdef->name << std::endl;
									}
									return _T('?');
								}
								break;
							case 1:
								if (pos_eq == NULL) {
									++optind;
									optarg = argv[optind];
								}
								else {
									optarg = (TCHAR*)pos_eq + 1;
								}
								break;
							}
							++optind;
							nextchar = 0;
							if (longindex != 0) {
								*longindex = index_found;
							}
							if (optdef->flag != 0) {
								*optdef->flag = optdef->val;
								return 0;
							}
							return optdef->val;
						}
						continue;
					}
				}
				optptr = _tcschr(optstring, c);
				if (optptr == NULL) {
					optopt = c;
					if (opterr) {
						std::wcerr << argv[0] << L"invalid option -- " << c << std::endl;
					}
					++nextchar;
					return _T('?');
				}
				if (*(optptr + 1) != _T(':')) {
					nextchar++;
					if (*(argv[optind] + nextchar) == _T('\0')) {
						++optind;
						nextchar = 0;
					}
					optarg = 0;
				}
				else {
					nextchar++;
					if (*(argv[optind] + nextchar) != _T('\0')) {
						optarg = argv[optind] + nextchar;
					}
					else {
						++optind;
						if (optind < argc - postpone_count) {
							optarg = argv[optind];
						}
						else {
							optopt = c;
							if (opterr) {
								std::wcerr << argv[0] << L": option requires an argument -- " << c << std::endl;
							}
							if ( optstring[0] == _T(':') ||
								(optstring[0] == _T('-') || optstring[0] == _T('+')) &&
								 optstring[1] == _T(':'))
							{
								c = _T(':');
							}
							else {
								c = _T('?');
							}
						}
					}
					++optind;
					nextchar = 0;
				}
				return c;
			}

			while ((argc - optind - postpone_count) > 0) {
				postpone(optind);
				++postpone_count;
			}

			nextchar = 0;
			postpone_count = 0;
			return -1;
		}

	public:

		GetOpts(int _argc, TCHAR* _argv[], LPCTSTR _optstring) : argc(_argc), argv(_argv), optstring(_optstring) {}

		int getopt()
		{
			return _getopt_( 0, 0);
		}
		int getopt_long(const struct option* longopts, int* longindex)
		{
			return _getopt_(longopts, longindex);
		}

		LPTSTR getoptarg() { return optarg; }
	};
}

//debug:
//-c 0 -l -t t23
//-c 0 -d
void usage(LPCTSTR argv0)
{
	std::wcerr << _T("利用方法") << std::endl;
	std::wcerr <<  argv0 << _T("-f [ファイル名] -c [カメラ番号] [-d(Detection Mode)|-l(Learning Mode)] -t [ターゲット名] -s(学習モードで撮影をスキップ)") << std::endl;
	return;
}

int _tmain(int argc, TCHAR** argv, TCHAR** envp)
{
	using ModCap=t23::ModCapture;
	void usage(LPCTSTR);
	CString     fileName;
	CString     targetName;
	int         camId = -1;
	int  opt = _T('\0');
	bool        skipCapture = false;

	t23::GetOpts opts(argc, argv, _T("f:c:dlt:s"));

	t23::CapMode capMode = t23::CapMode::Undefined;

	while((opt=opts.getopt()) != -1){
		switch (opt) {
		case _T('f'):
			fileName = opts.getoptarg();
			break;
		case _T('c'):
			camId = _tcstol(opts.getoptarg(), nullptr, 10);
			if (errno) {
				camId = -1;
			}
			break;
		case _T('d'):
			capMode = t23::CapMode::FaceDetect;
			break;
		case _T('l'):
			capMode = t23::CapMode::FaceCollect;
			break;
		case _T('t'):
			targetName = opts.getoptarg();
			break;
		case _T('s'):
			skipCapture = true;
			break;
		default:
			break;
		}
	}

	if (capMode == t23::CapMode::Undefined) {
		std::wcerr << "エラー：撮影モードを指定してください(-d(認識モード)/-l(学習モード)" << std::endl;
		return -1;
	}

	if (camId < 0 && fileName.GetLength() == 0) {
		std::wcerr << "エラー：カメラＩＤまたはファイルが指定されていません(-c 0～999)" << std::endl;
		return -1;
	}
	if(capMode==t23::CapMode::FaceCollect && targetName.GetLength()==0){
		std::wcerr << "エラー：対象者名を指定してください(-t [苗字])" << std::endl;
		return -1;
	}
	try {
		if(capMode==t23::CapMode::FaceCollect){
			if (camId >= 0) {
				std::unique_ptr<ModCap> modCap(new ModCap(camId, capMode, skipCapture));
				modCap->startCapture(targetName, false);
			}
			else {
				std::unique_ptr<ModCap> modCap(new ModCap(fileName, capMode, skipCapture));
				modCap->startCapture(targetName, false);
			}
		}
		else if(capMode==t23::CapMode::FaceDetect){
			if (camId >= 0) {
				std::unique_ptr<ModCap> modCap(new ModCap(camId, capMode));
				modCap->startCapture();
			}
			else {
				std::unique_ptr<ModCap> modCap(new ModCap(fileName, capMode));
				modCap->startCapture();
			}
		}
	}
	catch (std::exception e) {
		std::wcerr << e.what() << std::endl;
	}

	return 0;
}