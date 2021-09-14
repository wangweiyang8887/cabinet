// Copyright © 2021 evan. All rights reserved.

final class DatePickerView : UIControl {
    private enum Component: Int {
        case year, month

        var calendarComponent: Calendar.Component {
            switch self {
            case .month: return .month
            case .year: return .year
            }
        }
    }

    // MARK: Content
    private var calendar: Calendar = Calendar.autoupdatingCurrent {
        didSet {
            monthDateFormatter.calendar = calendar
            monthDateFormatter.timeZone = calendar.timeZone
            yearDateFormatter.calendar = calendar
            yearDateFormatter.timeZone = calendar.timeZone
        }
    }

    private lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView(frame: self.bounds)
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
        return pickerView
    }()

    private lazy var monthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("M")
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()

    private lazy var yearDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("y")
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter
    }()

    var date = Date() {
        didSet {
            let newDate = calendar.startOfDay(for: date)
            setDate(newDate, animated: true)
            sendActions(for: .valueChanged)
        }
    }

    var selectedDate: Date? {
        didSet {
            let newDate = given(selectedDate) { calendar.startOfDay(for: $0) } ?? Date()
            setDate(newDate, animated: true)
        }
    }

    var minimumDate = CalendarDate.minimum.date(in: .current)
    var maximumDate = CalendarDate.maximum.date(in: .current)
    var valueEditedHandler: ((CalendarDate?) -> Void)?

    // MARK: Lifecycle
    init() {
        super.init(frame: .zero)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    private func initialize() {
        addSubview(pickerView, pinningEdges: .all)
        calendar.timeZone = .current
        setDate(date, animated: false)
    }

    private func setDate(_ date: Date, animated: Bool) {
        guard let yearRange = calendar.maximumRange(of: .year), let monthRange = calendar.maximumRange(of: .month) else { return }
        let month = calendar.component(.month, from: date) - monthRange.lowerBound
        pickerView.selectRow(month, inComponent: Component.month.rawValue, animated: animated)
        let year = calendar.component(.year, from: date) - yearRange.lowerBound
        pickerView.selectRow(year, inComponent: Component.year.rawValue, animated: animated)
    }
}

extension DatePickerView : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard let yearRange = calendar.maximumRange(of: .year), let monthRange = calendar.maximumRange(of: .month), let dayRange = calendar.maximumRange(of: .day) else { return }
        var dateComponents = DateComponents()
        let selectedYear = pickerView.selectedRow(inComponent: Component.year.rawValue)
        let selectedMonth = pickerView.selectedRow(inComponent: Component.month.rawValue)
        dateComponents.year = yearRange.lowerBound + selectedYear
        dateComponents.month = monthRange.lowerBound + selectedMonth
        dateComponents.day = dayRange.lowerBound + 1 // To the guaranteed date starts on the 1st.
        guard let date = calendar.date(from: dateComponents)?.constrained(to: minimumDate...maximumDate) else { return }
        self.selectedDate = date
        self.date = date
        valueEditedHandler?(CalendarDate(date: date, timeZone: .current))
    }
}

extension DatePickerView : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let component = Component(rawValue: component) else { return 0 }
        guard let range = calendar.maximumRange(of: component.calendarComponent) else { return 0 }
        return range.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard let component = Component(rawValue: component) else { return nil }
        guard let range = calendar.maximumRange(of: component.calendarComponent) else { return nil }
        var dateComponents = DateComponents()
        switch component {
        case .month:
            dateComponents.month = range.lowerBound + row
            guard let date = calendar.date(from: dateComponents) else { return nil }
            return monthDateFormatter.string(from: date)
        case .year:
            dateComponents.year = range.lowerBound + row
            guard let date = calendar.date(from: dateComponents) else { return nil }
            return yearDateFormatter.string(from: date)
        }
    }
}

extension CalendarDate {
    static var maximum = CalendarDate(year: 2100, month: 12, day: 31)
    static var minimum = CalendarDate(year: 1980, month: 1, day: 1)
}
