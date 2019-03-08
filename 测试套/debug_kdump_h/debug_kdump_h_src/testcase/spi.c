#include <linux/module.h>
#include <linux/of_mdio.h>
#include <linux/platform_device.h>
//#include <linux/mbi.h>
#include <linux/interrupt.h>

#define BASE_ADDR 0x4d000000 
#define SIZE 0x10000
#define OFFSET 0x40
#define HW_IRQ 207 

static irqreturn_t test_interrupt(int irq, void *dev_id)
{
	pr_info("\nhandle spi. before panic, cpu id: %d\n", smp_processor_id());

	panic("spi.\n");

	return IRQ_HANDLED;
}

static void trigger_SPI(void)
{
	char *v = (char *)ioremap(BASE_ADDR, SIZE);
	
	pr_info("before writel_relaxed\n");

	writel_relaxed(HW_IRQ, v + OFFSET);
}

static int m_init(struct platform_device *pdev)
{
	int virq;
	int ret = 0;
	struct device *dev = &pdev->dev;

	virq = platform_get_irq(pdev, 0);
	if (virq > 0)
		ret = devm_request_irq(dev, virq, test_interrupt,
				       0, pdev->name, NULL);

	pr_info("m_init virq:%d ret:%d\n", virq, ret);

	trigger_SPI();
		
	return ret;
}

static int m_exit(struct platform_device *pdev)
{
	return 0;
}

static const struct of_device_id test_of_match[] = {
	{ .compatible = "test,spitest" },
	{}
};

static struct platform_driver test_driver = {
	.driver = {
		.name = "test-driver",
		.of_match_table = test_of_match,
	},
	.probe = m_init,
	.remove = m_exit,
};

module_platform_driver(test_driver);
MODULE_DEVICE_TABLE(of, test_of_match);
MODULE_LICENSE("GPL");

