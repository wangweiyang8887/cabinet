// Copyright © 2021 evan. All rights reserved.

final class DatePickerVC : BaseBottomSheetVC {
    // MARK: Nested types
    enum DateType { case yearMonth, yearMonthDay, dateAndTime }

    // MARK: Content
    private var pickerView: DatePickerView?
    private var datePicker: UIDatePicker?
    private let dateType: DateType
    private let timeZone: TimeZone

    var minimumDate: Date { didSet { handleMinimumDateSet() } }
    var maximumDate: Date { didSet { handleMaximumDateSet() } }
    var selectedDate: Date? { didSet { handleSelectedDateSet() } }
    var valueEditedHandler: ((Date) -> Void)?

    // MARK: Lifecycle
    init(title: String, dateType: DateType, timeZone: TimeZone = .current) {
        (self.dateType, self.timeZone) = (dateType, timeZone)
        minimumDate = CalendarDate.minimum.date(in: timeZone)
        maximumDate = CalendarDate.maximum.date(in: timeZone)
        super.init(style: .action(title: title))
        actionHandler = { [unowned self] in self.done() }
    }

    required init?(coder: NSCoder) { 🔥 }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.isScrollEnabled = false
        collectionView += BaseSection([ pickerRow ])
        handleMinimumDateSet()
        handleMaximumDateSet()
        handleSelectedDateSet()
    }

    // MARK: Components
    private lazy var pickerRow: BaseRow = {
        let row = BaseRow()
        switch dateType {
        case .yearMonth:
            let picker = DatePickerView()
            picker.selectedDate = selectedDate
            picker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
            row.contentView.addSubview(picker, pinningEdges: .all)
            pickerView = picker
        case .yearMonthDay, .dateAndTime:
            let picker = UIDatePicker()
            picker.datePickerMode = dateType == .yearMonthDay ? .date : .dateAndTime
            picker.timeZone = timeZone
            picker.locale = Locale(identifier: "zh_CN")
            if #available(iOS 13.4, *) {
                picker.preferredDatePickerStyle = .wheels
            } else {
                // Fallback on earlier versions
            }
            row.contentView.addSubview(picker, pinningEdges: .all)
            datePicker = picker
        }
        row.hideSeparators()
        return row
    }()

    // MARK: Actions
    @objc
    private func dateChanged(_ sender: DatePickerView) {
        selectedDate = sender.selectedDate
    }

    private func done() {
        switch dateType {
        case .yearMonthDay, .dateAndTime: selectedDate = datePicker!.date
        case .yearMonth: break
        }
        guard let date = selectedDate else { return }
        valueEditedHandler?(date)
    }

    // MARK: Utilities
    private func handleMinimumDateSet() {
        pickerView?.minimumDate = minimumDate
        datePicker?.minimumDate = minimumDate
    }

    private func handleMaximumDateSet() {
        pickerView?.maximumDate = maximumDate
        datePicker?.maximumDate = maximumDate
    }

    private func handleSelectedDateSet() {
        guard let date = selectedDate else { return }
        pickerView?.selectedDate = date
        datePicker?.setDate(date, animated: false)
    }

    // MARK: General
    func show(on viewController: UIViewController = UIViewController.current()) {
        viewController.presentPanModal(self)
    }
}
